# Day 10: Multi-Stage Docker Builds & Non-Root Execution

## Overview
Optimized a Go HTTP service Docker image using multi-stage builds, enforced least privilege using a non-root user, and evaluated a minimal scratch image.

## Measured Image Sizes
- Single-Stage (`demo:single`): 1.31 GB
- Multi-Stage (`demo:multi`): 19 MB
- Scratch (`demo:scratch`): 6.87 MB
- Builder Stage (`demo:build`): 441 MB

**Reduction**: ~98.5% reduction from single-stage to multi-stage.

## Key Verifications
1. Application endpoints: `/` returns `Hello from a multi-stage build!` and `/health` returns `ok`.
2. Non-root user: Container runs with `uid=100(app)` instead of root (`uid=0`).
3. Builder target: Built independently via `docker build --target builder`.
