# Day 20: Health Probes, Resources & Autoscaling (HPA)

## 📌 Overview
Configured health probes (Startup, Readiness, Liveness), set CPU/memory requests and limits, inspected QoS classes, deployed Kubernetes Metrics Server, and verified auto-scaling using Horizontal Pod Autoscaler (HPA).

---

## 🛠️ Key Implementations
- **Probes**: Configured `startupProbe`, `readinessProbe`, and `livenessProbe` for graceful container lifecycle handling.
- **Resource Management**: Defined requests (`cpu: 200m`, `memory: 64Mi`) and limits (`cpu: 500m`, `memory: 128Mi`), establishing a **Burstable** QoS class.
- **Metrics Server**: Configured metrics-server to allow resource tracking via `kubectl top`.
- **HPA**: Configured scaling between 1 and 5 replicas targeting 50% CPU utilization.
- **Safe Failure Testing**: Tested readiness probe failure and verified traffic removal without unwanted restarts.

---

## 📸 Evidence
Screenshots and verification outputs are saved in the `evidence/` directory.

---

## 💡 Interview Q&A
- **Readiness vs Liveness**: Readiness determines traffic eligibility without restarting; Liveness detects stuck containers and restarts them.
- **Startup Probe**: Gives slow-starting applications time to initialize before readiness/liveness checks take over.
- **QoS Classes**: Guaranteed (requests == limits for all containers), Burstable (some requests/limits set), BestEffort (no limits or requests).
- **HPA Dependency**: Requires CPU requests to calculate utilization percentages accurately.
