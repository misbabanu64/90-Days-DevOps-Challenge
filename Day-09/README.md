# Dockerfile Deep Dive - Day 02 Assignment

A production-grade Docker packaging for a Node.js HTTP API demonstrating optimal layer caching, safe runtime configurations, and process execution behavior.

## 1. Project Overview & Architecture
- Base Image: node:20-alpine
- Security: Runs as non-root user node
- Context Hygiene: Clean build context using .dockerignore

## 2. Dockerfile Breakdown
- FROM node:20-alpine: Pulls lightweight Node Alpine base image.
- WORKDIR /app: Defines safe working directory.
- ARG APP_VERSION=1.0: Build-time argument.
- ENV PORT=3000 APP_ENV=dev APP_VERSION=$APP_VERSION: Persistent container environment variables.
- COPY package*.json ./: Copies package files first for build cache.
- RUN npm install --omit=dev: Installs production dependencies.
- COPY . .: Copies remaining source code.
- EXPOSE 3000: Documents port metadata.
- USER node: Enforces non-root least privilege.
- CMD ["node", "server.js"]: Default startup command in exec form.

## 3. Key Concepts
- Layer Caching: Unchanged dependency steps show CACHED when only source files change.
- CMD vs ENTRYPOINT: ENTRYPOINT sets fixed executable; CMD provides default arguments that can be overridden.
- COPY vs ADD: COPY is for regular file transfers; ADD handles archive extraction and remote URLs.
- ARG vs ENV: ARG is build-time only; ENV persists in the running container.

## 4. Evidence of Completion
- Health Check: evidence/health-check.png
- Dynamic Env Override: evidence/env-override.png
- Cache Hit: evidence/cache-hit.png
- ENTRYPOINT Test: evidence/entrypoint-test.png
