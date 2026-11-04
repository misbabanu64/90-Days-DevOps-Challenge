# Day 34 – Kubernetes Deployment & Operations Lab

Part of the **DevOps Winter Arc – 90 Days DevOps Challenge** (Revision Week).

## Objective

Deploy the application from Days 30–33 to a local Kubernetes cluster, configure a Service and runtime settings, then verify health, scaling, rollout, and recovery.

## Environment

| Item | Value |
|------|-------|
| Cluster | Kind (cluster name: `day17`) |
| Namespace | `day34-revision` |
| Image | `winter-arc-app:day32` |
| Container port | `3000` |
| Service | `revision-app` (ClusterIP, port 80 → targetPort 3000) |
| Health endpoint | `/health` |
| Replicas | 2 (scaled to 3 during the lab) |

## Project Structure

```
Day-34/
├── k8s/
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── evidence/
│   └── (screenshots)
└── README.md
```

## Manifests Summary

- **configmap.yaml** – `app-config` with non-secret settings: `APP_ENV=revision`, `PORT=3000`.
- **deployment.yaml** – `revision-app`, 2 replicas, image `winter-arc-app:day32`, `imagePullPolicy: IfNotPresent`, `containerPort: 3000`, config injected from `app-config`, plus readiness and liveness probes on `/health`.
- **service.yaml** – ClusterIP Service `revision-app` routing port 80 to container port 3000 using selector `app: revision-app`.

No secrets or credentials are stored in any manifest.

## Deploy Steps

### 1. Verify cluster and create namespace

```bash
kubectl config current-context
kubectl get nodes -o wide
kubectl create namespace day34-revision
kubectl get namespace day34-revision
```

### 2. Load the image into Kind

```bash
docker images | grep winter-arc-app
kind get clusters
kind load docker-image winter-arc-app:day32 --name day17
```

### 3. Apply manifests and verify

```bash
kubectl apply -f k8s/
kubectl -n day34-revision get deploy,pods,svc
kubectl -n day34-revision rollout status deployment/revision-app
```

Result: both Pods reached `1/1 Running`.

## Access the Application

Terminal 1:

```bash
kubectl -n day34-revision port-forward svc/revision-app 8080:80
```

Terminal 2:

```bash
curl -i http://localhost:8080/
curl -i http://localhost:8080/health
```

Result: `HTTP/1.1 200 OK` on both endpoints; `/health` returned `"status":"healthy"`.
Stop port-forward with `Ctrl+C`.

## Runtime Configuration and Probes

- Non-secret configuration lives in a ConfigMap, separate from the image.
- The app has a real `/health` endpoint, so HTTP probes were used:
  - **Readiness** (`initialDelaySeconds: 5`, `periodSeconds: 5`) controls whether a Pod receives traffic.
  - **Liveness** (`initialDelaySeconds: 15`, `periodSeconds: 10`) restarts the container if it becomes unhealthy.

## Scaling

```bash
kubectl -n day34-revision scale deployment/revision-app --replicas=3
kubectl -n day34-revision get pods
kubectl -n day34-revision get deployment revision-app
```

Result: 3/3 Pods Ready.

## Rollout and Rollback

A rollout was triggered with a safe, harmless update (no broken or public images used).

```bash
kubectl -n day34-revision rollout history deployment/revision-app
kubectl -n day34-revision rollout undo deployment/revision-app
kubectl -n day34-revision rollout status deployment/revision-app
```

Result: Deployment reverted to the previous revision successfully.

## Issue Diagnosed and Fixed

**Problem:** Creating the namespace failed with an RFC 1123 validation error.

```bash
kubectl create namespace Day-34-revision
```

**Diagnosis:** Kubernetes resource names must be lowercase alphanumeric characters or `-`, and must start and end with an alphanumeric character. The uppercase `D` violated the regex.

**Fix:** Used the lowercase name.

```bash
kubectl create namespace day34-revision
```

## Evidence (Screenshots)

Located in `evidence/`:

| # | File | Shows |
|---|------|-------|
| 1 | `1-Deployment-pods-&-Service-pods.png` | Deployment, Pods (desired replicas Ready) and Service |
| 2 | `2-port-forward-curl-response.png` | Successful app response via port-forward |
| 3 | `4-scaling-and-rollout-rollback.png` | Scaling to 3, rollout history, rollback success |
| 4 | `5-troubleshooting-fix.png` | Namespace error diagnosis and fix |

## Troubleshooting Quick Reference

| Symptom | What to check |
|---------|---------------|
| ImagePullBackOff | Image/tag, `kind load docker-image`, `imagePullPolicy` |
| CrashLoopBackOff | `kubectl logs`, command, config, port |
| Service unreachable | Service selector vs Pod labels, `targetPort` |
| Probe failures | Endpoint path, port, app logs |
| Stuck rollout | `rollout status`, `describe pod`, events |

Useful commands:

```bash
kubectl -n day34-revision describe deployment revision-app
kubectl -n day34-revision describe pod POD_NAME
kubectl -n day34-revision logs deployment/revision-app
kubectl -n day34-revision get events --sort-by=.lastTimestamp
```

## Interview Quick-Check

1. **Deployment vs Pod:** A Deployment manages ReplicaSets and keeps the desired number of Pods running.
2. **ClusterIP:** A stable in-cluster endpoint for a set of selected Pods.
3. **Readiness vs liveness:** Readiness decides traffic eligibility; liveness triggers container restarts.
4. **ConfigMap:** Stores non-sensitive configuration separately from the image.
5. **Rollout undo:** Reverts a Deployment to a previous revision.

## Cleanup

```bash
kubectl delete namespace day34-revision
```

## Completion Checklist

- [x] Cluster verified
- [x] Deployment and Service applied
- [x] ConfigMap and probes configured
- [x] App accessed via port-forward
- [x] Scale and rollback tested
- [x] README and screenshots ready

## Key Learnings

- Kubernetes names must follow RFC 1123 (lowercase only).
- Kind needs local images loaded explicitly with `kind load docker-image`.
- Readiness and liveness probes serve different purposes.
- `rollout undo` makes recovery quick and safe.
