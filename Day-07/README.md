# DevOps Winter Arc — Day 07: Git Workflows & Nginx Reverse Proxy Debugging

## Overview
Day 7 focused on bridging developer version control workflows with real-world production infrastructure troubleshooting. The objective was to manage isolated Git feature branches, handle remote Pull Request merges via GitHub, and diagnose an upstream outage through Nginx reverse proxy error logs.

---

## What I Practiced & Implemented

### 1. Git Version Control & Branching Workflow
- Initialized a local Git tracking repository and configured user identity.
- Created and isolated features using branch switching (`feature/status-page`, `feature/health-check`).
- Configured `.gitignore` rules to keep untracked runtime logs and local dependencies out of version control.
- Executed local branch merges and resolved upstream branch pointers.

### 2. GitHub Collaboration & Pull Request (PR)
- Authenticated remote repository pushes via GitHub Personal Access Token (PAT).
- Pushed isolated feature branches to the remote repository.
- Opened a formal Pull Request on GitHub for `feature/health-check` into `master`.
- Reviewed, approved, and merged the PR using GitHub's web interface, followed by pulling changes locally (`fast-forward`).

### 3. Nginx Reverse Proxy Configuration
- Deployed a lightweight backend HTTP service running on port 3000.
- Configured an Nginx virtual host (`/etc/nginx/sites-available/day7`) mapping local domain `day7.local` to `127.0.0.1:3000` via `proxy_pass`.
- Updated `/etc/hosts` for local DNS resolution and validated end-to-end proxying returning `200 OK`.

### 4. Production Outage Simulation & RCA (502 Bad Gateway)
- **Simulated Outage**: Terminated the upstream Python service on port 3000 while Nginx remained active.
- **Client Impact**: Incoming requests to `http://day7.local` failed with **HTTP 502 Bad Gateway**.
- **Root Cause Analysis (RCA)**: Inspected `/var/log/nginx/error.log` to trace root failure:
  ```text
  connect() failed (111: Connection refused) while connecting to upstream, upstream: "[http://127.0.0.1:3000/](http://127.0.0.1:3000/)"



  
