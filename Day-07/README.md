# DevOps Winter Arc - Day 7: Git, GitHub & Reverse Proxy Troubleshooting

## Project Overview
Demonstrated Git branching workflows, GitHub Pull Requests, and Nginx reverse proxy configuration with 502 Bad Gateway troubleshooting.

## Files & Incident Report
- Tested branches: feature/health-check
- Reverse proxy domain: day7.local -> 127.0.0.1:3000
- Incident Report: Simulated upstream outage, analyzed `/var/log/nginx/error.log` (111: Connection refused), and verified 200 OK service recovery.
