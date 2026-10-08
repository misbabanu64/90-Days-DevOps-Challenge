# 🚀 Day 06 — Storage, Monitoring & Debugging

> **90 Days DevOps Challenge | DevOps Universe**

## 🎯 Objective

Today's practice focused on Linux storage, system monitoring, filesystem management, and troubleshooting a controlled disk-full incident.

## 📚 Tasks Completed

### 1. Linux Storage Inspection

* Inspected disks and filesystems using `lsblk`
* Checked filesystem information using `lsblk -f`
* Checked storage usage using `df -h` and `df -Th`

### 2. Disk Usage Analysis

* Used `du` to identify directories consuming disk space
* Compared filesystem usage with directory/file usage

### 3. System Health Monitoring

* Checked memory using `free -h`
* Checked uptime and load using `uptime`
* Checked failed services using `systemctl --failed`

### 4. Safe Test Filesystem

* Created a 100 MB test disk image
* Formatted it with `ext4`
* Mounted it at `/mnt/day6disk`

### 5. Persistent Mounting

* Retrieved the filesystem UUID
* Configured `/etc/fstab`
* Validated the configuration using `mount -a` and `findmnt`

### 6. Disk Usage Testing

* Created controlled test data
* Monitored storage usage using `df` and `du`

### 7. Disk-Full Incident

* Simulated a controlled "No space left on device" scenario
* Checked filesystem and inode usage
* Identified large files consuming storage

### 8. Troubleshooting & Incident Report

Followed the troubleshooting process:

**Problem → Evidence → Root Cause → Fix → Verification**

* Confirmed the storage issue
* Collected evidence using `df`, `df -i`, and `du`
* Identified the files consuming space
* Removed only the test files
* Verified that free space was restored

## 💡 Key Learning

I learned that effective DevOps troubleshooting is not about guessing.

A structured approach is:

**Confirm the symptom → Collect evidence → Find the resource → Identify the root cause → Apply a safe fix → Verify the result**

## ✅ Day 06 Completed

Continuing my hands-on DevOps learning journey.

**Day 06/90 — Completed 🚀**

#DevOps #Linux #DevOpsJourney #LearningInPublic
