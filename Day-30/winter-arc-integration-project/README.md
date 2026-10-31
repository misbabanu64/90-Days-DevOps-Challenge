# DevOps Winter Arc: 7-Day Integration Project (Day 30–36)

## Project Overview
- **Project Name:** Deploy, Monitor & Recover a Containerized Application
- **Selected App:** Node.js Express REST API (Endpoints: `/` and `/health`)
- **Hosting Strategy:** Local-first on Linux/WSL2, Docker, and kind Kubernetes. AWS architecture is conceptual only.

---

## 7-Day Roadmap

| Day | Focus Area | Milestone Goal |
|---|---|---|
| **Day 30** | Kickoff + Planning | Repo scaffold, choose app, architecture, revision tracker |
| **Day 31** | Linux + Networking | Run app directly on Linux; users, permissions, logs, ports |
| **Day 32** | Docker | Dockerfile, non-root user, container health test |
| **Day 33** | Docker Compose | Multi-container setup, environment, volume persistence |
| **Day 34** | Kubernetes (kind) | Deployment, Service, Probes, Rollback test |
| **Day 35** | AWS Design | VPC, ALB, Private Subnets, IAM security |
| **Day 36** | Break/Fix & Recovery | Induce failure, recover service, document RCA |

---

## Revision Tracker

| Skill Domain | Specific Topics | Status | 7-Day Revisit Plan |
|---|---|---|---|
| **Linux** | Commands, permissions (`chmod`/`chown`), users | Confident | Day 31 verification |
| **Linux** | Service troubleshooting, logs (`journalctl`), ports (`ss`) | Need practice | **Weak Area #1**: Deep dive on Day 31 |
| **Docker** | Container run, inspect, port binding | Confident | Day 32 test |
| **Docker** | Non-root security, lean image build, Docker Compose | Need practice | **Weak Area #2**: Enforce in Day 32 & 33 |
| **Kubernetes** | Deployments, Services, ClusterIP/NodePort | Confident | Day 34 validation |
| **Kubernetes** | Liveness/Readiness probes, rolling updates, rollbacks | Need practice | **Weak Area #3**: Hands-on fault injection on Day 34 |
| **AWS** | VPC, Subnets, Route Tables, Internet Gateway | Confident | Day 35 architecture mapping |
| **AWS** | Least privilege IAM, ALB Target Groups | Need practice | Review during Day 35 design |

### Selected Top 3 Weak Areas:
1. **Linux Service & Log Troubleshooting:** Mastering `journalctl`, systemd services, and network ports.
2. **Container Security:** Enforcing non-root execution inside Docker containers.
3. **Kubernetes Health Probes & Rollbacks:** Recovering crashed pods and rolling back failed deployments.

---

## Interview Warm-up (Day 30)
- **Q: Image vs Container?**
  - **A:** An image is a static, read-only template containing code and libraries. A container is a running instance of that image.
- **Q: What does a Kubernetes Service provide?**
  - **A:** A stable network endpoint (IP and DNS) to route traffic to ephemeral Pods.
- **Q: Why keep an AWS app tier private?**
  - **A:** To prevent direct internet exposure and enforce secure routing exclusively through an ALB.
- **Q: Why use logs in troubleshooting?**
  - **A:** Logs provide timestamped execution details and stack traces essential for identifying root causes.
