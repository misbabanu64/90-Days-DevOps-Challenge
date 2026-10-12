# Day 11: Docker Storage & Networking 💾🌐

## 📌 Executive Summary
As part of the **90 Days of DevOps Challenge**, Day 11 focuses on **Docker Storage Management** and **Container Networking Architectures**.

By default, container filesystems are ephemeral—data created inside a container is lost when the container is deleted. To achieve production stability, data must persist across container lifecycles using **Docker Volumes**. Additionally, microservices require decoupled and isolated communication networks. This project proves how **User-Defined Bridge Networks** enable automatic DNS name resolution and service discovery, tests backup and recovery procedures, and demonstrates port allocation troubleshooting.

---

## 🏗️ Architecture & Core Concepts

### 1. Storage: Volumes vs. Bind Mounts vs. Tmpfs
| Storage Type | Managed By | Host Location | Persistence | Best Use Case |
|---|---|---|---|---|
| **Named Volume** | Docker Engine | `/var/lib/docker/volumes/` | Survives container deletion | Production databases, persistent logs |
| **Bind Mount** | Host OS / User | Any host filesystem path | Survives container deletion | Source code hot-reloading in development |
| **tmpfs Mount** | Linux Kernel | Host memory (RAM) | Destroyed on stop | Sensitive data, temporary cache |

### 2. Networking: Default Bridge vs. User-Defined Bridge
- **Default Bridge (`bridge`)**: Legacy Docker network. Containers cannot resolve each other by container name.
- **User-Defined Bridge (`app-net`)**: Modern Docker network. Includes an internal DNS server that resolves container names to private IP addresses automatically.

---

## 🛠️ Hands-on Step-by-Step Implementation

### Step 1: Named Volume & Database Persistence Drill
1. Created an isolated bridge network and a persistent named volume:
   ```bash
   docker network create app-net
   docker volume create pgdata
