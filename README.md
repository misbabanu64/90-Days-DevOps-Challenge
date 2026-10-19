# 90 Days DevOps Challenge

My hands-on DevOps learning journey: Linux, Git, Networking, Nginx, Docker, Docker Compose and Container Security. Every day has its own folder with commands, evidence (screenshots/reports) and a README explaining what I did and learned.

**Status:** Day 15 of 90 completed 🚀

## Progress

| Day | Topic | Folder |
|-----|-------|--------|
| 01 | DevOps Winter Arc kickoff | [Day-01](Day-01) |
| 02 | Linux Fundamentals | [Day-02](Day-02) |
| 03 | Linux File & Directory Operations | [Day-03](Day-03) |
| 04 | Networking, SSH & Connectivity | [Day-04](Day-04) |
| 05 | DNS, HTTP/HTTPS & Nginx | [Day-05-DNS-HTTP-NGINX](Day-05-DNS-HTTP-NGINX) |
| 06 | Storage, Monitoring & Debugging | [Day-06](Day-06) |
| 07 | Git Workflows & Nginx Reverse Proxy Debugging | [Day-07](Day-07) |
| 08 | Docker Fundamentals | [Day-08](Day-08) |
| 09 | Dockerfile Deep Dive | [Day-09](Day-09) |
| 10 | Multi-Stage Docker Builds & Non-Root Execution | [Day-10](Day-10) |
| 11 | Docker Storage & Networking | [Day-11](Day-11) |
| 12 | Docker Compose: Flask + PostgreSQL + Redis | [Day-12](Day-12) |
| 13 | Docker Security & Optimization (Trivy) | [Day-13](Day-13) |
| 14 | Docker in CI/CD (GitHub Actions) | [Day-14](Day-14) |
| 15 | Kubernetes Fundamentals (Nginx on kind) | [Day-15](Day-15-Kubernetes-Fundamentals) |
| 16 | Deployments & Rollouts (rolling updates, rollback) | [Day-16](Day-16-Deployments-Rollouts) |
| 17 | Services & Networking (ClusterIP, DNS, EndpointSlices) | [Day-17](Day-17-Services-Networking) |
| 18 | Kubernetes ConfigMaps, Secrets & Namespaces | [Day-18](./Day-18-ConfigMaps-Secrets-Namespaces) |
| 19 | In Progress | Coming Soon |

## Highlights

- **Day 12:** One `compose.yaml` runs Flask + PostgreSQL + Redis with health checks, `service_healthy` dependencies, a named volume and restart policy.
- **Day 13:** Reduced an unsafe image from 1.77 GB to 185 MB and HIGH findings from 401 to 44 (CRITICAL 16 to 0) using Trivy, a non-root user, runtime secrets and a hardened `docker run`. Remaining findings are documented, not hidden.
- **Day 14:** GitHub Actions pipeline lints the Dockerfile (Hadolint), builds the image, runs a smoke test and a Trivy scan (action pinned to `0.35.0`), then pushes an immutable SHA tag to Docker Hub. A paths filter runs it only when Day-14 files or the workflow change.
- **Day 15:** Deployed Nginx on a local kind Kubernetes cluster using Deployment and NodePort Service YAML manifests, scaled to 3 replicas, verified access with port-forward, and demonstrated self-healing by deleting a Pod.

## Skills I am building

Linux | Git | Networking | Nginx | Docker | Docker Compose | Trivy / DevSecOps | AWS | CI/CD | Kubernetes (upcoming)

## How each day is organised

Each `Day-XX` folder contains the code or configs, an `evidence/` folder with screenshots or reports, and a README with commands, observations and troubleshooting. No real secrets are committed.

## Connect

LinkedIn: [Misba Banu](https://www.linkedin.com/in/misba-banu-793567257/)

Learning in public, one day at a time. 💪
