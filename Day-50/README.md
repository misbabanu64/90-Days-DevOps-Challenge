# DevOps Winter Arc - Day 50: Kubernetes Production Break-and-Fix Lab

## Goal
Diagnose and repair common Kubernetes production failure modes (`ImagePullBackOff`, `CrashLoopBackOff`, Service selector mismatches, PVC Pending states, and NetworkPolicy CNI behavior) inside an isolated, disposable local namespace (`day50-lab`) using an evidence-based troubleshooting workflow.

---

## Troubleshooting Workflow
1. **Observe symptom:** Check resource status (`kubectl get all -n day50-lab`).
2. **Inspect status and events:** Examine Pod/Service descriptions and cluster events (`kubectl describe`, `kubectl get events`).
3. **Check logs and configuration:** Inspect container logs (`--previous` for crashed containers) and manifest specs.
4. **Identify root cause:** Pinpoint the exact configuration or runtime failure.
5. **Make the smallest safe fix:** Apply targeted patches or image/spec updates without disrupting healthy workloads.
6. **Verify recovery:** Confirm rollout completion, `1/1 Running` Pod states, and populated `EndpointSlices`.

---

## Lab Environment & Safety Setup
- **Cluster:** Local Kind cluster (`kind-day41`)
- **Isolated Namespace:** `day50-lab` (Zero cloud/AWS resources created)

```bash
kubectl config current-context
kubectl create namespace day50-lab
kubectl config set-context --current --namespace=day50-lab
```

---

## Deliverables: Break-and-Fix Exercises

### Exercise A: `ImagePullBackOff`
- **Symptom:** Pod `bad-image-*` remained stuck in `0/1` `ErrImagePull` / `ImagePullBackOff` state.
- **Diagnostic Commands & Output:**
  ```bash
  kubectl create deployment bad-image --image=nginx:tag-does-not-exist -n day50-lab
  kubectl get pods -n day50-lab
  kubectl describe pod <pod-name> -n day50-lab
  ```
  *Events Output:* `Failed to pull image "nginx:tag-does-not-exist": failed to resolve reference "docker.io/library/nginx:tag-does-not-exist": not found`.
- **Root Cause:** The Deployment referenced a non-existent image tag (`nginx:tag-does-not-exist`) that could not be resolved or pulled from Docker Hub.
- **Fix:** Updated the Deployment container image to a valid existing tag (`nginx:1.27`):
  ```bash
  kubectl set image deployment/bad-image *=nginx:1.27 -n day50-lab
  ```
- **Verification:**
  ```bash
  kubectl rollout status deployment/bad-image -n day50-lab
  kubectl get pods -n day50-lab
  ```
  *Result:* `deployment "bad-image" successfully rolled out` and Pod transitioned to `1/1 Running`.
- **Prevention Tip:** Always pin verified, immutable image tags (or SHA256 digests) validated in CI pipelines before deploying to Kubernetes.

---

### Exercise B: `CrashLoopBackOff`
- **Symptom:** Pod `crash-demo-*` repeatedly terminated with `Error` and entered `CrashLoopBackOff` with increasing restart counts.
- **Diagnostic Commands & Output:**
  ```bash
  kubectl create deployment crash-demo --image=busybox:1.36 -n day50-lab -- /bin/sh -c "exit 1"
  kubectl get pods -n day50-lab
  kubectl get events -n day50-lab --sort-by='.lastTimestamp'
  ```
  *Events Output:* `Warning BackOff: Back-off restarting failed container busybox in pod crash-demo-*`.
- **Root Cause:** The container ran `/bin/sh -c "exit 1"`, exiting immediately with a non-zero status code. Because a Deployment requires a continuously running foreground process, Kubernetes repeatedly restarted the container with exponential backoff.
- **Fix:** Patched the container's `command` field to run a long-lived foreground process (`sleep 36000`):
  ```bash
  kubectl patch deployment crash-demo -n day50-lab --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value": ["sh", "-c", "sleep 36000"]}]'
  ```
- **Verification:**
  ```bash
  kubectl rollout status deployment/crash-demo -n day50-lab
  kubectl get pods -n day50-lab
  ```
  *Result:* `deployment "crash-demo" successfully rolled out` and Pod remained stable at `1/1 Running` with `0` restarts.
- **Prevention Tip:** Ensure application containers run a persistent foreground process (PID 1) and validate container entrypoint commands locally prior to deployment.

---

### Exercise C: Service Selector Mismatch
- **Symptom:** Service `web-svc` had no backend endpoints (`ENDPOINTS` showed `<unset>`), preventing traffic routing to `web-demo` Pods.
- **Diagnostic Commands & Output:**
  ```bash
  kubectl create deployment web-demo --image=nginx:1.27 -n day50-lab
  kubectl expose deployment web-demo --name=web-svc --port=80 --target-port=80 -n day50-lab
  kubectl patch service web-svc -n day50-lab -p '{"spec":{"selector":{"app":"wrong-app"}}}'
  kubectl get pods --show-labels -n day50-lab
  kubectl describe service web-svc -n day50-lab
  kubectl get endpointslices -n day50-lab
  ```
  *Output:* Pod had label `app=web-demo`, whereas `web-svc` selector was `app=wrong-app`, resulting in `<unset>` endpoints in `EndpointSlices`.
- **Root Cause:** The Service's `spec.selector` (`app=wrong-app`) did not match the Pod template labels (`app=web-demo`), so the EndpointSlice controller could not associate any Ready Pods with the Service.
- **Fix:** Restored the Service selector to match the Pod's `app=web-demo` label:
  ```bash
  kubectl patch service web-svc -n day50-lab -p '{"spec":{"selector":{"app":"web-demo"}}}'
  ```
- **Verification:**
  ```bash
  kubectl get endpointslices -n day50-lab
  kubectl get deploy,rs,pods,svc -n day50-lab
  ```
  *Result:* `EndpointSlices` immediately populated with the `web-demo` Pod IP address, and all workloads were `1/1 Running`.
- **Prevention Tip:** Manage Service selectors and Deployment Pod labels from shared variables/templates in Helm or Kustomize so they cannot drift independently.

---

### Exercise D: PVC Pending Investigation
- **Symptom:** PersistentVolumeClaims (PVCs) remain stuck in `Pending` state instead of binding to a PersistentVolume (PV).
- **Diagnostic Commands & Output:**
  ```bash
  kubectl get storageclass
  kubectl get pv
  kubectl get pvc -A
  ```
  *Output:* Cluster uses `standard (default)` StorageClass (`rancher.io/local-path`) with `WaitForFirstConsumer` binding mode; no PVs or PVCs currently exist.
- **Root Causes (Two Common Reasons):**
  1. **No Matching PV or Missing/Broken Dynamic Provisioner:** Either no static PV satisfies the requested storage size/access mode, or the referenced `StorageClass` is missing/misconfigured so dynamic provisioning fails.
  2. **`WaitForFirstConsumer` Volume Binding Mode:** When a StorageClass uses `WaitForFirstConsumer`, the PVC intentionally stays `Pending` until a Pod using that PVC is scheduled onto a specific node.
- **Verification & Safety:** Inspected cluster storage state non-destructively without creating cloud disks or altering StorageClasses.
- **Prevention Tip:** Verify `StorageClass` availability, provisioner controller health, and `volumeBindingMode` expectations before deploying stateful workloads.

---

### Exercise E: NetworkPolicy Investigation (Optional)
- **Symptom:** Applying a `NetworkPolicy` resource succeeds in the Kubernetes API, yet Pod-to-Pod traffic restriction is not enforced.
- **Diagnostic Commands & Output:**
  ```bash
  kubectl get pods -n kube-system
  ```
  *Output:* Cluster networking is managed by `kindnet-fbpmx`.
- **Root Cause:** Kind uses `kindnet` as its default CNI plugin, which handles basic Pod networking/routing but does **not** implement NetworkPolicy enforcement.
- **Verification:** Confirmed CNI plugin in `kube-system` without applying policies outside `day50-lab`.
- **Prevention Tip:** Use a NetworkPolicy-capable CNI plugin (such as Calico or Cilium) in clusters where micro-segmentation and ingress/egress policies are required.

---

## Interview Questions & Answers

1. **What is the difference between `ImagePullBackOff` and `CrashLoopBackOff`?**
   - **`ImagePullBackOff`** happens *before* the container starts: the kubelet cannot pull the container image from the registry (due to an invalid image name/tag, missing `imagePullSecrets`, or network/registry auth issues).
   - **`CrashLoopBackOff`** happens *after* the image is pulled and the container starts: the container process crashes or exits repeatedly, and Kubernetes waits with an exponential backoff delay before restarting it again.

2. **How do you investigate a `Pending` Pod?**
   - Run `kubectl describe pod <pod-name> -n <namespace>` and check the **Events** section for scheduler messages (e.g., `Insufficient cpu/memory`, node taints/tolerations mismatch, nodeSelector/affinity rules not matching any node, or unbound `Pending` PVCs).

3. **Why can a Service have no endpoints (`<none>` / `<unset>`)?**
   - Either the Service's `spec.selector` does not match the labels on any Pods in the same namespace, or matching Pods exist but are not in a `Ready` state (e.g., failing readiness probes or crashing).

4. **How do you view logs from a previous crashed container?**
   - Run `kubectl logs <pod-name> --previous -n <namespace>` (or `-p`), which retrieves stdout/stderr logs from the container instance that crashed prior to the latest restart.

5. **Why should you inspect events before changing resources?**
   - Cluster events (`kubectl describe` / `kubectl get events`) provide exact, evidence-based reasons from the scheduler, kubelet, and controllers (such as image pull errors, probe failures, or volume mount errors). Checking events first prevents guesswork and avoids making unnecessary or destructive configuration changes.

---

## Cleanup & Verification
Confirmed active context and deleted only the disposable lab namespace:
```bash
kubectl config current-context
kubectl delete namespace day50-lab
kubectl config set-context --current --namespace=default
kubectl get ns
```

---

## Screenshots Included
1. `1-imagepullbackoff.png` — `ImagePullBackOff` status and Events before repair.
2. `2-crashloopbackoff.png` — `CrashLoopBackOff` status and Events before repair.
3. `3-service-mismatch.png` — Service selector mismatch (`app=wrong-app` vs `app=web-demo`) and empty `EndpointSlices`.
4. `4-verified-fixes.png` — Successful rollouts, `1/1 Running` Ready Pods, and populated `EndpointSlices` after fixes.
5. `5-root-cause-summary.png` — Concise root-cause and verification summary.
