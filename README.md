# Day 21: Kubernetes Security, RBAC & Troubleshooting

**DevOps Winter Arc | Day 21/90**

## Overview

This practical lab focuses on Kubernetes security, Role-Based Access Control (RBAC), ServiceAccounts, Pod Security Standards, and troubleshooting broken Deployments using an existing Kind cluster.

## Objectives

- Implement least-privilege access using RBAC.
- Create a dedicated ServiceAccount and RoleBinding.
- Verify permissions using `kubectl auth can-i`.
- Enforce the Restricted Pod Security Standard.
- Run a hardened Pod as a non-root user.
- Troubleshoot and repair three broken Deployments.

## Technologies Used

- Kubernetes
- kubectl
- Kind
- YAML
- Linux Terminal
- Git and GitHub

## 1. RBAC and ServiceAccount

Created a `secure` namespace and a dedicated ServiceAccount named `viewer`.

Configured a Role named `pod-reader` with read-only permissions for Pods and Pod logs, and connected it using a RoleBinding.

### Permission Verification

```bash
kubectl auth can-i get pods -n secure \
  --as=system:serviceaccount:secure:viewer

kubectl auth can-i delete pods -n secure \
  --as=system:serviceaccount:secure:viewer
```

**Expected results:**
- Get Pods: `yes`
- Delete Pods: `no`

This demonstrates the principle of least privilege.

## 2. Pod Security and Hardening

Applied the Restricted Pod Security Standard to the `secure` namespace.

```bash
kubectl label namespace secure \
  pod-security.kubernetes.io/enforce=restricted
```

Created a hardened Pod using the following security settings:

- `runAsNonRoot: true`
- `runAsUser: 10001`
- `allowPrivilegeEscalation: false`
- `readOnlyRootFilesystem: true`
- `capabilities.drop: ["ALL"]`
- `seccompProfile: RuntimeDefault`

These settings reduce unnecessary privileges and improve container security.

### Verification

```bash
kubectl get pod secure-pod -n secure
kubectl describe pod secure-pod -n secure
```

Tested a root-based Pod to verify that the Restricted policy rejects non-compliant workloads.

## 3. Kubernetes Troubleshooting

Created three broken Deployments in the `lab` namespace and investigated their symptoms before applying fixes.

### Troubleshooting Commands

```bash
kubectl get deployments,pods -n lab

kubectl describe pod <pod-name> -n lab

kubectl logs <pod-name> -n lab --previous

kubectl get events -n lab --sort-by=.lastTimestamp
```

### Issues Identified and Fixes

| Deployment | Symptom | Root Cause | Fix |
|---|---|---|---|
| broken1 | ImagePullBackOff | Invalid image tag | Updated to a valid NGINX image |
| broken2 | CrashLoopBackOff | Container command exited with code 1 | Changed to a valid long-running command |
| broken3 | Pending | 64Gi memory request could not fit on the Kind node | Reduced memory request to 64Mi |

### Example Fix Commands

```bash
kubectl set image deployment/broken1 -n lab nginx=nginx:1.27

kubectl set resources deployment/broken3 -n lab \
  --requests=memory=64Mi
```

For `broken2`, updated the container command to keep the process running.

## 4. Debugging Workflow

Followed an evidence-first troubleshooting approach:

1. `kubectl get` — inspect resource status.
2. `kubectl describe` — review resource details and Events.
3. `kubectl logs` — inspect application logs.
4. `kubectl get events` — identify cluster-level issues.
5. `kubectl exec` — investigate inside a running container when needed.

## 5. Project Structure

```text
day21-security-debug/
├── README.md
├── rbac.yaml
└── secure-pod.yaml
```

## 6. Key Learnings

- Implemented namespace-scoped RBAC permissions.
- Practised ServiceAccount and RoleBinding configuration.
- Verified allowed and denied actions using `kubectl auth can-i`.
- Applied container security settings and Restricted Pod Security.
- Diagnosed image-pull, application-crash, and resource-scheduling failures.
- Used Kubernetes Events and logs to identify root causes before fixing issues.

## 7. Evidence and Screenshots

Add your actual screenshots below to document the completed practical work.

- RBAC permission checks showing `yes` for reading Pods and `no` for deleting Pods.
- Restricted Pod Security rejecting a non-compliant root-based Pod.
- All three repaired Deployments and their Pods reaching the expected healthy state.

## 8. Interview Preparation

**What is RBAC?**  
RBAC controls who can perform which actions on which resources and within what scope.

**What is the difference between Role and ClusterRole?**  
A Role is namespace-scoped, while a ClusterRole can apply cluster-wide or be reused across namespaces.

**What is CrashLoopBackOff?**  
It indicates that a container repeatedly starts and exits. Check its logs, previous logs, and Pod Events.

**Why use a non-root container?**  
It reduces the potential impact of a compromised or faulty application.

**How do you troubleshoot a Pending Pod?**  
Describe the Pod and inspect Events for scheduling constraints or insufficient resources.

## Conclusion

Completed hands-on practice in Kubernetes RBAC, least-privilege access, Pod security hardening, and troubleshooting broken Deployments as part of the DevOps Winter Arc 90-Day Challenge.

**Focus:** Secure workloads, investigate evidence, and apply the smallest safe fix.

#DevOps #Kubernetes #RBAC #CloudComputing #DevOpsWinterArc #LearningByDoing

