# Day 10: Multi-Stage Docker Builds & Non-Root Execution

## Overview
Aaj Day 10 ke assignment me Go HTTP service ko optimize kiya gaya. Ek badi single-stage Docker image ko replace karke lightweight multi-stage image banayi gayi aur container ko non-root user se run kiya gaya.

## What We Did Today
1. Single-Stage Image (`demo:single`) build ki jiska size 1.31 GB tha.
2. Multi-Stage Dockerfile banaya jisme builder stage se sirf binary copy ki runtime stage me.
3. Multi-Stage Image (`demo:multi`) ka size sirf 19 MB nikla (~98.5% reduction).
4. Container ko non-root user `app` (`uid=100`) par run kiya least privilege security ke liye.
5. Endpoints test kiye: `/` and `/health`.
6. Builder stage ko independently verify kiya (`demo:build`).
7. Bonus minimal image test ki (`demo:scratch` - 6.87 MB).

## Image Size Comparison
- Single-Stage (`demo:single`): 1.31 GB
- Multi-Stage (`demo:multi`): 19 MB
- Builder Target (`demo:build`): 441 MB
- Scratch Variant (`demo:scratch`): 6.87 MB

## Verification
- Non-Root: `docker exec demo id` returned `uid=100(app)`
- Endpoints: `curl http://localhost:8080/` returned `Hello from a multi-stage build!`
