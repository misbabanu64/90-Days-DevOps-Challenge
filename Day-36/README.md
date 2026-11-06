# DevOps Winter Arc - Day 36: Final Integration, Break/Fix & Demo

## Purpose
A small Node.js app (port 3000) used to show the full delivery path:
Linux -> Docker -> Compose -> Kubernetes -> proposed AWS design.

## Architecture
Linux host (WSL) -> Docker image winter-arc-app:v1 -> Docker Compose (1 service)
-> Kubernetes (kind cluster, namespace day36, 2 replicas + ClusterIP Service)
-> AWS design (design only, not deployed): Route 53 -> ALB -> ECS Fargate (private subnets).

## Prerequisites
Docker, Docker Compose, kubectl, kind (cluster day17), WSL/Linux shell.

## Ports and dependencies
- App port: 3000. Endpoints: / and /health
- Dependencies: none (no database, so persistence checks are N/A)

## Run with Docker
docker build -t winter-arc-app:v1 -f docker/Dockerfile .
docker run -d --name winter-arc-container -p 3000:3000 winter-arc-app:v1
curl http://localhost:3000/health

## Run with Compose
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml ps
docker compose -f docker/docker-compose.yml down

## Run on Kubernetes
kind load docker-image winter-arc-app:v1 --name day17
kubectl create namespace day36
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl -n day36 rollout status deployment/winter-arc-app
kubectl -n day36 port-forward svc/winter-arc-svc 8080:80
curl http://localhost:8080/health

## Validation summary
| Layer | Result |
|---|---|
| Linux (port 3000 listening, node process) | PASS |
| Docker (image, status, port map, logs) | PASS |
| Compose (service up, restart, response) | PASS |
| Kubernetes (2/2 ready, endpoints, access, events) | PASS |
| AWS design | Explained (design only) |

## AWS design (DESIGN ONLY - NOT DEPLOYED)
See aws-design/aws-design.md

## Incident report
See docs/incident-report.md
Summary: Deployment scaled 2 -> 0 (Option C), app became unreachable, endpoints showed none,
restored by scaling back to 2, verified with rollout status and /health.
Extra: Option A (docker stop/start) also tested on the Docker container.

## Screenshots
See screenshots/ folder (5 files).

## Limitations
- No database, so no persistence test.
- Container exits with code 137 on stop (no graceful shutdown).
- AWS part is a design only.

## Next improvements
- Add SIGTERM handler for graceful shutdown.
- Add CI/CD pipeline and image versioning.
- Deploy the AWS design with Terraform and cost alerts.
