# DevOps Winter Arc - Day 08: Docker Fundamentals

## Overview
Learned core Docker architecture, container lifecycles, custom image creation using Dockerfiles, and practical port collision troubleshooting.

## Tasks Completed
1. **Docker Setup & Verification**: Verified Docker daemon status and server specs via `docker --version` and `docker info`.
2. **First Container**: Tested image-to-container workflow with `hello-world`. Explored difference between `docker ps` and `docker ps -a`.
3. **Web Server Setup**: Ran lightweight Nginx on mapped ports using detached mode (`-d`).
4. **Custom Web App**: Created custom landing page (`index.html`).
5. **Dockerfile & Image Build**: Authored a lightweight Dockerfile using `nginx:alpine` and built `day8-web:1.0`.
6. **Container Execution**: Exposed and verified the custom container on host port 8081.
7. **Inspection & Resource Monitoring**: Analyzed container metadata with `docker inspect`, container logs via `docker logs`, and live resource metrics via `docker stats --no-stream`.

## Troubleshooting Incident (Port Conflict)
- **Problem**: Host port 8080 collision during initial Nginx container run.
- **Evidence**: Accessing port 8080 loaded an existing local Jenkins instance instead of the Nginx welcome page.
- **Root Cause**: Host port 8080 was bound by a pre-existing local service.
- **Fix**: Remapped Nginx to port 8085 (`-p 8085:80`) and custom app to port 8081 (`-p 8081:80`).
- **Verification**: Verified HTTP 200 OK via `curl` and confirmed clean browser rendering.
