 Day 12: Docker Compose Multi-Container Stack

## 📌 Project Overview
Orchestrating a multi-service web architecture using **Docker Compose**. The stack connects a Python Flask API to a PostgreSQL relational database and an in-memory Redis cache with health checks, persistent volumes, and fault recovery.

---

## 🏛 Architecture Diagram
+-------------------------------------------------------------+
|                     Host Machine (:5000)                    |
+-------------------------------------------------------------+
|
v
+-------------------------------------------------------------+
|                Docker Bridge Network                        |
|                                                             |
|   +-------------------+                                     |
|   |    web (Flask)    | <------ Port 5000                   |
|   +-------------------+                                     |
|         |          |                                        |
|         | (db:5432)| (redis:6379)                           |
|         v          v                                        |
|   +----------+   +------------+                             |
|   | db (PG)  |   |   redis    |                             |
|   +----------+   +------------+                             |
|        |               |                                    |
|   [pgdata vol]   [redisdata vol]                            |
+-------------------------------------------------------------+


---

## 🛠 Key Engineering Concepts
- **Service Discovery**: Containers communicate using internal DNS service names (`db`, `redis`) instead of host IP addresses.
- **Health Checks & Dependency Readiness**: Configured `pg_isready` and `redis-cli ping` with `depends_on: condition: service_healthy` to guarantee dependencies are ready before traffic starts.
- **Data Persistence**: Managed named volumes (`pgdata`, `redisdata`) ensure state survives container recreation lifecycles.
- **Fault Recovery**: Implemented `restart: unless-stopped` to automatically revive containers upon failure.
- **Secret Isolation**: Kept credentials out of Git via `.gitignore` while committing sanitized `.env.example`.

---

## 🚀 Execution & Verification Commands

### 1. Stack Initialization
```bash
docker compose config
docker compose up -d --build
docker compose ps
2. Endpoint & Health Checks
Bash
curl http://localhost:5000/
curl http://localhost:5000/health
3. Data Persistence Test
Bash
docker compose down
docker compose up -d
curl http://localhost:5000/
# Verified: PostgreSQL visit count continued incrementing without data loss.
4. Restart Policy Test
Bash
docker kill $(docker compose ps -q web)
docker compose ps

```
curl http://localhost:5000/
# Verified: Web container automatically recovered and bound to port 5000.


📸 Evidence & Artifacts
The test execution logs and visual verification are stored in the evidence/ directory:

01-compose-status.png: Stack running with healthy database and cache probes.

02-app-response.png: Root counter increments and /health reporting ok.

03-persistence-test.png: Persistent visits count across down and up lifecycles.

04-restart-test.png: Automatic recovery of the web service upon termination.

💬 Interview Readiness & Reflection
1. What problem does Docker Compose solve?

It provides a declarative, single-command orchestration layer for multi-container applications, automating networks, volumes, and service links.

2. Does depends_on guarantee database readiness?

No. By default, depends_on only waits for the container process to launch. Pairing it with a health check (pg_isready) and condition: service_healthy ensures true readiness.

3. Why use service name db instead of localhost?

Inside a container, localhost points strictly to that specific container's loopback interface. Docker's internal DNS network resolves the service name db to the database container IP.

4. What is the difference between down and down -v?

docker compose down removes containers and networks but preserves named volumes. docker compose down -v permanently destroys volumes along with their persistent data.
