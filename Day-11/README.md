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
Started a PostgreSQL 16 container mounting pgdata:

Bash
docker run -d --name db --network app-net \
  -e POSTGRES_PASSWORD=changeme -e POSTGRES_DB=shop \
  -v pgdata:/var/lib/postgresql/data postgres:16-alpine
Created a table and inserted a verification record:

Bash
docker exec -it db psql -U postgres -d shop -c \
  "CREATE TABLE notes(id serial, msg text); INSERT INTO notes(msg) VALUES ('I survive!');"
Verified row insertion:

Bash
docker exec db psql -U postgres -d shop -c "SELECT * FROM notes;"
Destruction & Recreation Test: Force-deleted the database container:

Bash
docker rm -f db
Re-spawned the container using the exact same volume:

Bash
docker run -d --name db --network app-net \
  -e POSTGRES_PASSWORD=changeme -v pgdata:/var/lib/postgresql/data postgres:16-alpine
docker exec db psql -U postgres -d shop -c "SELECT * FROM notes;"
Result: The record was instantly retrieved, confirming zero data loss.

Step 2: Cross-Container Communication & Embedded DNS Proof
Connected a client container on app-net to query the database using the hostname db:

Bash
docker run --rm -it --network app-net -e PGPASSWORD=changeme postgres:16-alpine \
  psql -h db -U postgres -d shop -c "SELECT count(*) FROM notes;"
DNS Resolution Scope Comparison:

Default Bridge Test (Failure):

Bash
docker run --rm alpine ping -c 1 db
Output: ping: bad address 'db'

Custom Bridge Test (Success via Docker DNS):

Bash
docker run --rm --network app-net alpine ping -c 1 db
Output: 64 bytes from 172.18.0.2: seq=0 ttl=64

Step 3: Volume Disaster Recovery (Backup & Restore)
Performed a backup of pgdata into a compressed tar archive:

Bash
docker run --rm -v pgdata:/data -v $(pwd):/backup alpine \
  tar czf /backup/pgdata-backup.tgz -C /data .
ls -lh pgdata-backup.tgz
Restored the backup archive into a new target volume (pgdata2):

Bash
docker volume create pgdata2
docker run --rm -v pgdata2:/data -v $(pwd):/backup alpine \
  tar xzf /backup/pgdata-backup.tgz -C /data
Step 4: Port Conflict Troubleshooting Drill
Started container w1 binding to host port 8080:

Bash
docker run -d --name w1 -p 8080:80 nginx:1.27-alpine
Attempted to allocate port 8080 to a second container w2:

Bash
docker run -d --name w2 -p 8080:80 nginx:1.27-alpine
Error Triggered: Bind for 0.0.0.0:8080 failed: port is already allocated

Diagnosed the port binding on the host OS:

Bash
ss -tulpn | grep 8080
Remapped container w2 to port 8081 to resolve the collision:

Bash
docker rm -f w2
docker run -d --name w2 -p 8081:80 nginx:1.27-alpine
📷 Practical Evidence & Verification
1. Initial Database Schema Creation & Record Insertion
Demonstrating creation of notes table and row insertion inside running PostgreSQL container.

2. Proof of Data Persistence (After Container Destruction)
Demonstrating data survival after docker rm -f db and attaching pgdata volume to a fresh container.

3. DNS Resolution Comparison (Default vs. Custom Bridge)
Comparing DNS failure on the default bridge vs. automatic embedded DNS resolution on app-net.

4. Volume Backup & Restoration Drill
Creating pgdata-backup.tgz (6.5MB) and extracting it into a fresh target volume (pgdata2).

5. Port Conflict Identification & Resolution
Diagnosing port is already allocated on 8080 using ss -tulpn and remapping service to port 8081.

🎯 Conclusion
All Day 11 requirements have been successfully completed:

Stateful workloads persist via Docker named volumes.

Microservices communicate reliably using custom bridge network DNS discovery.

Volume backup and restoration verified using temporary Alpine utility containers.

Host port conflicts resolved systematically using Linux network inspection tools.

🧹 Clean Up Command
Bash
docker rm -f w1 w2 db
