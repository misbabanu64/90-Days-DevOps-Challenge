# Architecture Design: 7-Day Integration Project

## 1. Local Runtime Architecture (Day 31 - Day 34)
This runs entirely locally on WSL2 / Docker / local Kubernetes (kind) without AWS cost.

```text
[ Client / Browser (localhost:3000) ]
                 │
                 ▼
     [ Linux Host / WSL2 Environment ]
                 │
                 ▼
   [ Docker Container / Kubernetes Pod ]
         (Node.js App on Port 3000)
                 │
     ┌───────────┴───────────┐
     ▼                       ▼
  GET / (Home)         GET /health (Health Check)
[ Internet Users ]
                                 │
                                 ▼ (Port 80/443)
                 [ Internet Gateway (IGW) ]
                                 │
                                 ▼
         [ Public Subnet: Application Load Balancer (ALB) ]
                                 │
                 ┌───────────────┴───────────────┐
                 │ (Private Routing via SG)      │
                 ▼                               ▼
 [ Private Subnet A: EC2/EKS Pod ] [ Private Subnet B: EC2/EKS Pod ]
                 │                               │
                 └───────────────┬───────────────┘
                                 ▼
              [ Private Subnet: RDS Database ]
