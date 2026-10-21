# 🚀 Day 20: Kubernetes Health, Resources & Autoscaling

![Kubernetes](https://img.shields.io/badge/Kubernetes-Hands--On-326CE5?logo=kubernetes&logoColor=white)
![DevOps](https://img.shields.io/badge/DevOps-Winter%20Arc-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

## 📌 Project Overview

As part of the **DevOps Winter Arc – 90 Days Challenge**, I worked on Kubernetes health monitoring, resource management, and automatic Pod scaling.

The objective was to deploy a resource-aware application, configure health probes, monitor CPU and memory usage, and use Horizontal Pod Autoscaler (HPA) to scale Pods based on CPU utilization.

## 🎯 What I Learned

- Verified Metrics Server and Kubernetes resource metrics.
- Configured CPU and memory requests and limits.
- Implemented Startup, Readiness, and Liveness probes.
- Inspected Kubernetes Quality of Service (QoS).
- Configured Horizontal Pod Autoscaler (HPA).
- Generated HTTP load and monitored autoscaling.
- Tested readiness probe failure and recovery.
- Practiced troubleshooting using `kubectl`.

## 🛠️ Tools & Technologies

- Kubernetes
- Kind
- kubectl
- Metrics Server
- Horizontal Pod Autoscaler
- BusyBox
- YAML

## 🏗️ Project Configuration

| Setting | Value |
|---|---|
| Application | php-apache |
| Namespace | `day20-health` |
| Initial replicas | 1 |
| Minimum replicas | 1 |
| Maximum replicas | 5 |
| Target CPU utilization | 50% |
| CPU request | 200m |
| CPU limit | 500m |
| Memory request | 64Mi |
| Memory limit | 128Mi |
| QoS class | Burstable |

## ❤️ Kubernetes Health Probes

| Probe | Purpose |
|---|---|
| Startup | Gives the application time to initialize. |
| Readiness | Controls whether a Pod receives Service traffic. |
| Liveness | Detects an unhealthy or stuck container and can trigger a restart. |

I tested readiness probe failure using an invalid endpoint, observed the Pod become NotReady, and restored the correct endpoint to verify recovery.

## 📊 Resource Management & QoS

Configured CPU and memory requests and limits to manage container resources.

- **Guaranteed:** Every container has matching CPU and memory requests and limits.
- **Burstable:** Resource requests or limits are configured, but the Pod does not meet Guaranteed criteria.
- **BestEffort:** No CPU or memory requests or limits are configured.

The application used the **Burstable** QoS class.

## 📈 Horizontal Pod Autoscaler (HPA)

Configured HPA to scale the `php-apache` Deployment according to CPU utilization.

- Minimum replicas: 1
- Maximum replicas: 5
- Target CPU utilization: 50%

Generated HTTP traffic using BusyBox and monitored CPU usage, HPA metrics, and Pod replicas. Observed scaling behavior under load and after stopping the load generator.

## 💻 Useful Commands

### Check resource metrics

```bash
kubectl top nodes
kubectl top pods -n day20-health
```

### Inspect Pods

```bash
kubectl get pods -n day20-health
kubectl describe pods -n day20-health
```

### Monitor HPA

```bash
kubectl get hpa -n day20-health
kubectl describe hpa -n day20-health
kubectl get hpa -n day20-health -w
```

### Watch Pod scaling

```bash
kubectl get deployments,pods -n day20-health -w
```

### Check events

```bash
kubectl get events -n day20-health --sort-by=.metadata.creationTimestamp
```

## 📸 Screenshots & Practical Evidence

The following screenshots should be stored in the `evidence/` directory.

### 1. Metrics Server Verification

![Metrics Server](evidence/01-metrics-server-top-nodes.png)

### 2. Deployment Resources and Health Probes

![Resources and Probes](evidence/02-deployment-describe-probes-resources.png)

### 3. QoS and Pod Resource Usage

![QoS and Resources](evidence/03-qos-burstable-top-pods.png)

### 4. HPA Configuration

![HPA Configuration](evidence/04-hpa-created-target-50.png)

### 5. Autoscaling Under Load

![HPA Scaling Up](evidence/05-hpa-scaling-up.png)

![Pods Scaled Up](evidence/06-pods-scaled-up.png)

### 6. Autoscaling After Load Stops

![HPA Scaling Down](evidence/7-hpa-scaling-down.png)

### 7. Readiness Probe Failure and Recovery

![Readiness Failure](evidence/08-readiness-fail-notready.png)

![Readiness Restored](evidence/10-readiness-restored.png)

> **Note:** These images require the actual screenshot files to be uploaded to `evidence/` with matching filenames. Update the paths if your filenames differ.

## 🔍 Troubleshooting

| Problem | What to Check |
|---|---|
| `kubectl top` fails | Metrics Server status, logs, and metrics availability |
| HPA shows `<unknown>` | Metrics Server, CPU requests, and collected metrics |
| Replicas do not increase | CPU usage, load generator, HPA events, and replica limits |
| Pods keep restarting | Probe configuration, logs, and events |
| Container is `OOMKilled` | Memory usage and configured memory limits |

## 🎓 Interview Questions

**1. What is the difference between Readiness and Liveness probes?**

Readiness controls traffic eligibility. Liveness detects an unhealthy or stuck container and can trigger a restart.

**2. Why does HPA need CPU requests?**

HPA calculates CPU utilization relative to the requested CPU.

**3. What does Metrics Server do?**

It provides CPU and memory metrics used by tools such as `kubectl top` and HPA.

**4. Does autoscaling guarantee better performance?**

No. Node capacity, database latency, and other bottlenecks can still affect performance.

## ✅ Key Takeaways

- Application health monitoring using Kubernetes probes.
- CPU and memory resource management.
- QoS classification and resource inspection.
- CPU-based autoscaling with HPA.
- Load testing and replica monitoring.
- Readiness failure testing and recovery.
- Kubernetes troubleshooting fundamentals.

## 🏁 Project Status

**Day 20 Completed** — Kubernetes Health Probes, Resource Management, QoS, Metrics Server, HPA, Load Testing, and Readiness Recovery.

**Challenge:** DevOps Winter Arc – 90 Days  
**Environment:** Kubernetes Kind Cluster

#DevOps #Kubernetes #CloudComputing #HPA #DevOpsWinterArc 
