 # Day 11: Docker Storage & Networking 🐳

## 📌 Overview
Part of the 90 Days of DevOps Challenge.
Hands-on practice of Docker Volumes, Custom Bridge Networks, DNS resolution, and Port troubleshooting.

---

## 🚀 Tasks Completed

### Task 1: Persistent PostgreSQL with Docker Volume
- Created custom bridge network `app-net` and volume `pgdata`.
- Inserted data into PostgreSQL container.
- Deleted container and recreated it with the same volume. Data was successfully retained.

### Task 2: Container Networking & DNS Verification
- Connected a client container on `app-net` to the database using hostname `db`.
- Verified that default bridge network fails DNS resolution, while custom bridge resolves `db` successfully.

### Task 3: Volume Backup and Restore
- Backed up `pgdata` volume into a compressed tar file `pgdata-backup.tgz`.
- Restored the backup archive into a new volume `pgdata2`.

### Task 4: Port Conflict Troubleshooting
- Simulated port allocation conflict on host port `8080`.
- Identified the port using `ss -tulpn | grep 8080`.
- Resolved the conflict by running the container on port `8081`.

---

## 📷 Screenshots
Screenshots uploaded in this folder.
