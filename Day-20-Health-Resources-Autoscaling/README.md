# Day 20: Health Probes, Resources & Autoscaling (HPA)

## 📌 Mission
Make an application self-checking, resource-aware, and able to scale from 1 to 5 Pods under CPU load[cite: 1].

---

## 🛠️ Tasks Breakdown

### Task A: Metrics Server Verification
- Installed metrics-server with `--kubelet-insecure-tls` for local kind cluster[cite: 1].
- Verified metrics availability using `kubectl top nodes` and `kubectl top pods`[cite: 1].

### Task B: Resource-Aware Deployment
- Deployed `php-apache` in namespace `day20-health`[cite: 1].
- Configured:
  - **Requests:** CPU: `200m`, Memory: `64Mi`[cite: 1]
  - **Limits:** CPU: `500m`, Memory: `128Mi`[cite: 1]
  - **Startup Probe:** HTTP GET `/` (failureThreshold: 30, periodSeconds: 2)[cite: 1]
  - **Readiness Probe:** HTTP GET `/` (initialDelaySeconds: 5, periodSeconds: 5)[cite: 1, 2]
  - **Liveness Probe:** HTTP GET `/` (initialDelaySeconds: 15, periodSeconds: 10)[cite: 2]

### Task C: Resource Inspection & QoS
- Inspected QoS class: **Burstable** (requests and limits are defined, but not equal).
- Monitored live container resource usage with `kubectl top pods -n day20-health`.

### Task D & E: Horizontal Pod Autoscaler (HPA) & Load Testing
- Configured HPA targeting 50% CPU utilization (`min: 1`, `max: 5`)[cite: 3].
- Simulated traffic using a busybox load generator[cite: 3]:
  ```bash
  kubectl run load-generator -n day20-health --image=busybox:1.36 --restart=Never -it --rm -- /bin/sh -c "while true; do wget -q -O- [http://php-apache.day20-health.svc.cluster.local](http://php-apache.day20-health.svc.cluster.local); done"
