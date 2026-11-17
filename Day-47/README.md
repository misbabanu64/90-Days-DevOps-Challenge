# Day 47: Kubernetes Production — Persistent Storage (PV, PVC & StorageClass)

## Overview
This directory documents **Day 47** of the **90 Days of DevOps Challenge (DevOps Winter Arc)**. The goal of this lab is to understand why container filesystems are not suitable for long-term stateful workloads and to implement persistent storage in Kubernetes using **PersistentVolumes (PV)**, **PersistentVolumeClaims (PVC)**, and **StorageClasses** on a local Kind cluster (`kind-day41`).

---

## Folder Structure

    Day-47/
    ├── README.md
    ├── storage-lab.yaml
    ├── evidence.txt
    └── screenshots/
        ├── 01-storageclass-list.png
        ├── 02-pvc-bound-pv-details.png
        ├── 03-pod-mount-data.png
        ├── 04-proof-before-delete.png
        └── 05-proof-after-recreate.png

---

## 1. Core Concepts Explained

- **Why Container Filesystems Are Not Suitable for Long-Term Data:** Container filesystems are ephemeral. Whenever a container crashes, restarts, or a Pod is deleted and recreated, any data written inside the container's writable layer is permanently lost.
- **Volume:** Storage mounted into a container whose lifecycle depends on the volume type (for example, `emptyDir` is temporary and deleted with the Pod, whereas persistent volumes outlive Pods).
- **PersistentVolume (PV):** A cluster-level storage resource provisioned either statically by an administrator or dynamically via a StorageClass. Its lifecycle is independent of any individual Pod.
- **PersistentVolumeClaim (PVC):** A namespace-scoped storage request created by a user or workload specifying desired capacity and access modes. Kubernetes binds the PVC to a suitable PV.
- **StorageClass:** Defines storage profiles/tiers and enables dynamic provisioning through a provisioner plugin, volume binding mode, and reclaim policy.
- **CSI Driver (Container Storage Interface):** A standardized plugin interface that connects Kubernetes to external or local storage systems to create, attach, mount, and delete volumes.
- **Reclaim Policy:** Defines what happens to a PV and its backing storage after its bound PVC is deleted (`Delete`, `Retain`, or `Recycle`).

---

## 2. Lab Execution & Verification Summary

### Environment & StorageClass Inspection
- **Cluster Context:** `kind-day41`
- **Lab Namespace:** `day47-lab`
- **Default StorageClass:** `standard`
  - **Provisioner:** `rancher.io/local-path`
  - **Reclaim Policy:** `Delete`
  - **Volume Binding Mode:** `WaitForFirstConsumer`
  - **Allow Volume Expansion:** `false`

### Manifest Deployed (`storage-lab.yaml`)
Created a `1Gi` `PersistentVolumeClaim` (`demo-pvc`) with `ReadWriteOnce` access mode and mounted it into a `busybox:1.36` Pod (`storage-demo`) at `/data`:

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: demo-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: storage-demo
    spec:
      containers:
        - name: app
          image: busybox:1.36
          command: ["sh", "-c", "while true; do sleep 3600; done"]
          volumeMounts:
            - name: app-storage
              mountPath: /data
      volumes:
        - name: app-storage
          persistentVolumeClaim:
            claimName: demo-pvc

### Binding, Data Persistence & Pod Recreation Test
1. **PVC & PV Binding:** Once `storage-demo` was scheduled, the `local-path` provisioner dynamically created PV `pvc-17979e18-b960-46c9-abef-1372f34726a7` (`1Gi`, `ReadWriteOnce`, `Delete`, `standard`) and bound `demo-pvc` (`Status: Bound`).
2. **Mount Verification:** Verified via `kubectl describe pod storage-demo` that `demo-pvc` was mounted at `/data` (`rw`).
3. **Write Test Before Deletion:** Created `/data/proof.txt` containing `Day47-storage-test` inside the running Pod.
4. **Pod Deletion & Recreation:** Deleted only the Pod (`kubectl delete pod storage-demo`) while keeping `demo-pvc` intact, then reapplied `storage-lab.yaml`.
5. **Post-Recreation Verification:** Confirmed `/data/proof.txt` still returned `Day47-storage-test`, proving data persisted across Pod lifecycles.

---

## 3. Reclaim Policy Analysis & Pod vs. PVC Deletion

- **Recorded PV Reclaim Policy:** `Delete`
- **Why Reclaim Policy Matters:** When a PV uses `Delete`, deleting its bound PVC automatically deletes both the PV resource and its backing storage—preventing orphaned cloud disks and unexpected billing, but causing permanent data loss if backups do not exist. A `Retain` policy preserves the PV and underlying disk for manual recovery.
- **Difference Between Deleting a Pod and Deleting a PVC:**
  - **Deleting a Pod:** Only terminates the container workload; the PVC remains `Bound` to the PV, and all data on the mounted path persists for future Pods claiming that PVC.
  - **Deleting a PVC:** Releases the storage claim. Depending on the PV's reclaim policy (`Delete` vs. `Retain`), this permanently erases the backing storage or leaves unattached cloud volumes incurring charges.

---

## 4. Issue Investigated & Troubleshooting Notes

- **Issue Investigated (`WaitForFirstConsumer` Binding Mode):** Investigated why `demo-pvc` initially stays in `Pending` status when created without a running Pod. Because the `standard` StorageClass uses `volumeBindingMode: WaitForFirstConsumer`, Kubernetes intentionally delays dynamic PV provisioning until a Pod referencing the PVC is scheduled, ensuring the storage is provisioned on the exact node where the Pod runs.
- **Common Storage Troubleshooting Checks:**
  - **PVC Pending:** Inspect `kubectl describe pvc <name>`, StorageClass provisioner availability, requested size, and access modes.
  - **Pod Pending / FailedMount:** Verify PVC `Bound` status, node events, and CSI driver health.
  - **Multi-Attach Error:** Occurs when a `ReadWriteOnce` block disk is still attached to another node.
  - **Permission Denied:** Check container `securityContext` (`fsGroup` / `runAsUser`) instead of using privileged containers.

---

## 5. Interview Questions & Answers

1. **What is the difference between a PV and a PVC?**
   A **PersistentVolume (PV)** is the actual storage resource in the cluster, whereas a **PersistentVolumeClaim (PVC)** is a workload's request for storage of a specific size and access mode.
2. **What is a StorageClass?**
   A **StorageClass** defines storage tiers and enables dynamic PV provisioning using a specified provisioner/CSI plugin, reclaim policy, and volume binding mode.
3. **What does `ReadWriteOnce` (RWO) mean?**
   `ReadWriteOnce` means the volume can be mounted as read-write by a single node at a time.
4. **Why can a PVC remain in a `Pending` state?**
   A PVC stays `Pending` if no matching PV exists, no valid/default StorageClass or provisioner is available, requested capacity/access modes cannot be satisfied, or the StorageClass uses `WaitForFirstConsumer` and no Pod has claimed it yet.
5. **What does a CSI driver do?**
   A **Container Storage Interface (CSI)** driver is a plugin bridge between Kubernetes and storage systems (such as AWS EBS, EFS, or local-path) that handles creating, attaching, mounting, and deleting volumes.
6. **Why should you check the reclaim policy before deleting a PVC?**
   Checking the reclaim policy beforehand prevents accidental permanent data loss (if set to `Delete`) and avoids leftover billable cloud disks (if set to `Retain`).

---

## 6. Safe Cleanup & Cost Verification

- Switched kubectl context back to the `default` namespace and removed the lab namespace (`kubectl delete namespace day47-lab`).
- Verified via `kubectl get pv` (`No resources found`) that the dynamically provisioned PV was cleanly removed with zero leftover storage resources.
