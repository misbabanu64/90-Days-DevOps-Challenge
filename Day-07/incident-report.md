# Production Incident Report - INC-001

## Incident Summary
- **Service Affected**: day7.local (Reverse Proxy & Backend)
- **Status Code Returned**: HTTP 502 Bad Gateway
- **Duration**: ~5 minutes
- **Impact**: Backend application unavailable to end users

## Root Cause Analysis
- The backend application listening on port 3000 was terminated.
- Nginx reverse proxy received requests on port 80 but could not connect to upstream `127.0.0.1:3000`.
- Log evidence from `/var/log/nginx/error.log`:
  `connect() failed (111: Connection refused) while connecting to upstream`

## Resolution & Recovery
- Restarted backend Python HTTP server process on port 3000.
- Verified service recovery via curl:
  - `curl -I http://day7.local` -> HTTP/1.1 200 OK
  - Verified content: "Day 7 Production App HEALTHY"
