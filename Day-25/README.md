# 🚀 Day 25: AWS EC2 Web Server Provisioning & Automated Bootstrapping

Part of the **DevOps Winter Arc 90 Days Challenge** (AWS Week - Day 3).

---

## 📌 Overview
The objective of Day 25 was to launch, configure, and secure an Amazon EC2 Linux virtual server, automate web server deployment using User Data (bootstrapping), examine EBS root volumes, and perform a mandatory cloud cleanup to maintain zero leftover cost.

---

## 🛠️ Architecture & Core Concepts Covered

- **Amazon EC2 (Elastic Compute Cloud):** On-demand scalable virtual compute in the cloud.
- **AMI (Amazon Machine Image):** Pre-configured template used to spin up instances (Amazon Linux 2023 / Ubuntu).
- **Security Group (Stateful Firewall):**
  - **Inbound SSH (Port 22):** Strictly locked down to `My IP` (security compliance: never `0.0.0.0/0`).
  - **Inbound HTTP (Port 80):** Open to `0.0.0.0/0` to serve web traffic.
- **Bootstrapping via User Data:** Injected a shell script executed automatically at first launch to install and enable Nginx without manual SSH intervention.
- **EBS (Elastic Block Store):** Verified root volume attachment and reviewed the `DeleteOnTermination` lifecycle behavior.

---

## ⚙️ User Data Bootstrap Script

```bash
#!/bin/bash
set -eux

# Detect package manager and install Nginx
if command -v dnf >/dev/null 2>&1; then
    dnf install -y nginx
else
    apt-get update -y
    apt-get install -y nginx
fi

# Enable and start Nginx service
systemctl enable --now nginx

# Deploy custom index page
cat <<EOF > /var/www/html/index.html
<h1>Hello from AWS EC2</h1>
<p>Day 25 DevOps Winter Arc</p>
EOF

if [ -d /usr/share/nginx/html ]; then
cat <<EOF > /usr/share/nginx/html/index.html
<h1>Hello from AWS EC2</h1>
<p>Day 25 DevOps Winter Arc</p>
EOF
fi
```

---

## 📋 Step-by-Step Implementation

1. **Planning & Safety:** Confirmed region boundaries (`ap-southeast-2`) and ensured no hardcoded credentials or `.pem` keys were committed.
2. **Key Pair Creation:** Generated RSA 2048-bit key pair (`day25-key.pem`) and stored it securely.
3. **Security Group Setup:** Attached a custom security group allowing port 22 (restricted to client IP) and port 80 (HTTP).
4. **Instance Launch:** Provisioned an Amazon Linux 2023 `t3.micro` instance with the User Data script injected under *Advanced Details*.
5. **Validation:**
   - Monitored status checks until **3/3 passed**.
   - Verified HTTP accessibility over public IPv4 in the browser (`Welcome to nginx!`).
6. **Mandatory Cleanup:** Terminated the instance and verified that the associated EBS root volume was detached and deleted to prevent residual charges.

---

## 📸 Proof of Work (Screenshots)

| Verification Step | Screenshot Description |
| :--- | :--- |
| **Nginx Web Page** | Verified public access to the Nginx web server over port 80. |
| **Instance Health Check** | AWS Console showing instance `Running` with `3/3 status checks passed`. |
| **Resource Cleanup** | AWS Console showing instance state as `Terminated` and volumes cleaned up. |

---

## 💡 Troubleshooting & Key Learnings

- **Region Constraints:** Handled default AWS Builder plan region lock safely by keeping the key pair, security group, and EC2 instance in the exact same region (`ap-southeast-2`).
- **Nginx Web Serving:** Understood that User Data runs as root during initialization. Verified that Nginx installed and started successfully upon first boot.
- **Cost Hygiene:** Reaffirmed that `Stop` preserves EBS volumes (incurring storage fees), whereas `Terminate` destroys the compute and attached root disk (preventing charges).

---

## 🎯 Completion Checklist
- [x] EC2 concepts understood (AMI, Instance Types, Key Pairs, Security Groups).
- [x] Inbound SSH restricted strictly to `My IP`.
- [x] Nginx bootstrapped automatically via User Data.
- [x] Web server verified over public IPv4.
- [x] Instance terminated and volumes verified for cleanup.
