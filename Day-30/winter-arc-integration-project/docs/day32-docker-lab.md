# Day 32: Docker Image & Container Revision Lab

## 1. Overview
Packaged the Node.js integration project application into an optimized Docker container with non-root security hardening and health checks.

## 2. Commands & Port Mapping
- **Build Command**: `docker build -t winter-arc-app:day32 .`
- **Run Command**: `docker run -d --name winter-arc-app -p 8080:3000 winter-arc-app:day32`
- **Port Mapping**: Host port 8080 forwards to container port 3000 (`8080:3000`)
- **Verification**: Verified using `curl -I http://localhost:8080` (HTTP 200 OK)

## 3. Security Hardening
- **Non-Root Execution**: Container runs under the `node` user (`uid=1000(node)`), verified with `docker exec winter-arc-app id`.
- **Build Context Exclusion**: Created `.dockerignore` to block `.env`, `.git`, and `node_modules` from entering the image.

## 4. Break/Fix Drill
- **Symptom**: `curl http://localhost:8080` returned `curl: (56) Recv failure: Connection reset by peer`.
- **Evidence**: `docker port winter-arc-app` revealed incorrect mapping (`5000/tcp -> 0.0.0.0:8080`).
- **Root Cause**: Host port 8080 was routed to container port 5000 instead of 3000 where the app listens.
- **Fix**: Stopped/removed container and redeployed with `-p 8080:3000`.
- **Verification**: `curl -I http://localhost:8080` returned `HTTP/1.1 200 OK`.
