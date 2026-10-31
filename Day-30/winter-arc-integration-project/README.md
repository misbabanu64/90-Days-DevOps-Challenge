# Winter Arc Integration Project

**Deploy, Monitor & Recover a Containerized Application**

> DevOps Winter Arc • Day 30/90 • Revision + Integration Project Kickoff
> Learn → Build → Break → Fix → Explain

---

## 1. Project Purpose

Days 1–29 covered Linux, Docker, Kubernetes and AWS as separate topics. This 7-day project (Day 30–36) connects them using **one single application**:

1. Run it on **Linux**
2. Containerize it with **Docker** and **Docker Compose**
3. Deploy it on **Kubernetes** (kind)
4. Represent it in an **AWS-ready architecture** (design only)

**Minimum outcome:** run the app, explain its traffic path, inspect logs, safely cause one failure, recover it, and document what happened.

---

## 2. Chosen App

| Item | Details |
|------|---------|
| Stack | Node.js + Express |
| Port | `3000` |
| `GET /` | Home page, returns app status |
| `GET /health` | Health endpoint, returns uptime (used for Docker/Kubernetes probes) |

The app is intentionally small. No extra features are added during the week.

---

## 3. Architecture

### 3.1 Local Architecture (runs on my machine, free and safe)

```
Browser
   │
   ▼
WSL2 Linux Host
   │
   ├──► Docker Container ──► Node.js App (port 3000)
   │
   └──► kind Cluster ──► Deployment ──► Pods ──► Service ──► Node.js App (port 3000)
```

### 3.2 AWS Architecture (DESIGN ONLY, nothing is deployed)

```
Internet
   │
   ▼
Internet Gateway
   │
   ▼
VPC
 ├── Public Subnets:   Application Load Balancer (ALB)
 └── Private Subnets:  App tier (EC2 / EKS Pods)
                          │
                          ▼
                       Private RDS Database
```

**Why the app tier is private:** it reduces direct exposure. Traffic enters only through a controlled point (the ALB).

Full notes: [`docs/architecture.md`](docs/architecture.md)

---

## 4. Repository Structure

```
winter-arc-integration-project/
├── app/             # Node.js/Express app (server.js, package.json)
├── linux/           # Day 31: Linux run, users, permissions, logs, ports
├── docker/          # Day 32-33: Dockerfile, Compose
├── kubernetes/      # Day 34: Deployment, Service, config, probes
├── aws-design/      # Day 35: AWS design and security notes
├── docs/            # Architecture and lessons learned
├── screenshots/     # Proof screenshots
├── .gitignore
└── README.md
```

---

## 5. Prerequisites

- Windows with WSL2 (Ubuntu)
- Git and a GitHub account
- Node.js and npm
- Docker (with Compose)
- kind and kubectl
- AWS account: **optional**, not needed for local work

### Run the app locally

```bash
cd app
npm install
node server.js
```

Test it from another terminal:

```bash
curl http://localhost:3000/
curl http://localhost:3000/health
```

---

## 6. 7-Day Roadmap

| Day | Focus | Milestone | Status |
|-----|-------|-----------|--------|
| 30 | Kickoff + planning | Choose app, repo, architecture, revision tracker | ✅ Done |
| 31 | Linux + networking | Run app on Linux; inspect users, permissions, services, logs, ports | ⬜ |
| 32 | Docker | Dockerfile; build/run image; test health and non-root execution | ⬜ |
| 33 | Docker Compose | App + optional DB; environment, health, persistent data | ⬜ |
| 34 | Kubernetes | Deploy on kind; Deployment, Service, config, probes, scaling, rollback | ⬜ |
| 35 | AWS design + security | Map app to AWS; IAM, VPC, ALB, EC2/EKS, private DB | ⬜ |
| 36 | Break/fix + demo | Test failure, recover, document lessons, demo, final checklist | ⬜ |

---

## 7. Revision Tracker

Legend: ✅ Confident • 🟡 Need practice • 🔴 Need help

| Area | Skills | Status |
|------|--------|--------|
| Linux | Commands, users, permissions | ✅ Confident |
| Linux | Process troubleshooting, logs (`journalctl`, `ss`) | 🟡 Need practice |
| Docker | Images, containers, volumes, networks, Compose | ✅ Confident |
| Docker | Container security (non-root execution) | 🟡 Need practice |
| Kubernetes | Deployment, Service, config | ✅ Confident |
| Kubernetes | Probes, rollout, failure recovery | 🟡 Need practice |
| AWS | IAM, VPC, EC2, RDS, EKS, ALB, Auto Scaling | ✅ Confident |

### Top 3 Weak Areas (to revisit in Day 31–36)

1. **Linux process troubleshooting and log analysis** (`journalctl`, `ss`) → Day 31
2. **Container security: non-root execution** → Day 32
3. **Kubernetes failure recovery: probe debugging and rollbacks** → Day 34 and 36

---

## 8. Safety and Cost Rules

- Project is **local-first** (WSL2, Docker, kind).
- **No paid AWS resources** are created without checking current costs first.
- A budget alert is **not** a hard spending cap.
- **Never commit** passwords, access keys, tokens, kubeconfig files, `.pem` or `.key` files, or secrets. `.gitignore` is configured to help prevent this.

---

## 9. Interview Warm-up

**Image vs container?**
An image is the packaged template; a container is a running instance of it.

**What does a Kubernetes Service provide?**
A stable way to reach selected Pods even when Pod IPs change.

**Why keep an AWS app tier private?**
It reduces direct exposure; traffic can enter through a controlled point such as an ALB.

**Why use logs in troubleshooting?**
They provide evidence about what the process or application did during a problem.

---

## 10. Screenshots

| File | What it shows |
|------|---------------|
| `01_repo_folder_structure.png` | Folder hierarchy |
| `02_architecture_diagram.png` | Architecture flow |
| `03_app_files_scaffold.png` | App files |
| `04_revision_tracker.png` | Revision tracker |
| `05_git_status_tracking.png` | Git tracking status |

---

## 11. Day 30 Reflection

**What I understand well:**
Docker basics, Compose, Kubernetes Deployments and Services, and the AWS VPC/ALB/private-tier design.

**What needs revision:**
Linux log analysis, non-root containers, and Kubernetes probe debugging and rollbacks.

---

## 12. Completion Checklist

- [x] Selected one small app for the entire week
- [x] Created the repository and folder structure
- [x] Documented local and AWS architecture separately
- [x] Marked revision strengths and weak areas
- [x] Understand the Day 31–36 plan; AWS stays optional and cost-aware

**Day 30 finish line:** One app selected • One repo created • One architecture drawn • Revision gaps identified

