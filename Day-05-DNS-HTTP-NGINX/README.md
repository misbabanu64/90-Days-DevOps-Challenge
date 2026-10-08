# 🚀 Day 05 — DNS, HTTP/HTTPS & Nginx

> 90 Days DevOps Challenge | DevOps Universe

## 🎯 Objective

Today's practice focused on DNS, HTTP/HTTPS, TLS, Nginx, reverse proxy configuration, hostname resolution, and troubleshooting a 502 Bad Gateway error.

## 📚 Tasks Completed

### 🌐 1. DNS & Hostname Resolution
- Used `dig` to inspect DNS records
- Used `dig +short` to find IP addresses
- Used `getent hosts` for hostname resolution

### 🌍 2. HTTP & HTTPS
- Tested HTTP requests using `curl`
- Inspected HTTP response headers
- Practiced HTTPS and TLS basics
- Learned common HTTP status codes

### ⚙️ 3. Nginx
- Installed Nginx
- Checked Nginx service status
- Verified port 80
- Tested Nginx using `curl`

### 🐍 4. Python Application
- Created a simple Python application
- Ran the application on port `3000`
- Verified the application response

### 🔄 5. Nginx Reverse Proxy
Configured Nginx to forward requests from:

`day5.local:80`

to:

`127.0.0.1:3000`

### 🛠️ 6. Troubleshooting
- Intentionally stopped the Python application
- Reproduced a `502 Bad Gateway`
- Checked listening ports
- Checked Nginx configuration and logs
- Restarted the application
- Verified the fix

## 🔁 Request Flow

```text
Client / curl
      ↓
day5.local
      ↓
/etc/hosts
      ↓
127.0.0.1
      ↓
Nginx :80
      ↓
Python App :3000
      ↓
Response
