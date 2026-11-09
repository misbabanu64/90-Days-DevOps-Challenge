# Day 38: AWS EKS Managed Node Groups & Capacity Planning

## Overview
Worker capacity in EKS comes from managed node groups (EC2 instances). This lab covers node group design, node/workload inspection on a local cluster (design-only path for AWS), scaling concepts, and troubleshooting.

---

## 1. Task A: Node Group Design

**Scenario:** Small stateless web app across 2 AZs.

| Parameter | Value | Rationale |
| :--- | :--- | :--- |
| Node group name | `web-app-ng-prod` | Identifies workload and environment |
| Instance type | `t3.medium` (investigate `m6i.large`) | Balanced CPU/memory for web pods |
| Min / Desired / Max | 2 / 2 / 4 | 2 nodes for multi-AZ; extra headroom for updates |
| Disk | 30 GiB gp3 | Images, logs, ephemeral storage |
| Subnets | 2 private subnets (one per AZ) | No public exposure |
| Labels | `role=web-frontend`, `workload=stateless` | nodeSelector / affinity |
| Taints | none | General stateless pods schedule freely |

### Diagram
```text
            EKS Control Plane (AWS managed)
                       |
        +--------------+--------------+
        |                             |
 Private Subnet AZ-a           Private Subnet AZ-b
  [Worker Node 1]               [Worker Node 2]
        \                             /
         +--- Managed Node Group ----+
                       |
            NAT Gateway / VPC Endpoints
                       |
                  Internet / AWS APIs
```

### Private subnets
Nodes have no public IPs. They reach the EKS API, ECR and CloudWatch via a NAT Gateway or VPC endpoints (PrivateLink).

### Node role vs Pod permissions
* **Node IAM role:** `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`. Only for node operation (join cluster, ENIs, image pulls).
* **Pod permissions:** separate, least-privilege roles via IRSA (Day 39). No broad permissions on the node role.

### Spare capacity for rolling updates
`max` > `desired` (4 vs 2) lets EKS add a surge node before draining old ones, without running extra nodes all the time.

---

## 2. Task B: AWS Inspection
Design-only path used (no EKS cluster; avoids cost). Commands for a real cluster:
```bash
aws eks list-nodegroups --cluster-name YOUR_CLUSTER --region YOUR_REGION
aws eks describe-nodegroup --cluster-name YOUR_CLUSTER --nodegroup-name YOUR_NODEGROUP --region YOUR_REGION
kubectl get nodes -o wide
kubectl get nodes --show-labels
```

---

## 3. Task C & D: Local Cluster Inspection (`day17-control-plane`)
Commands:
```bash
kubectl apply -f node-capacity-demo.yaml
kubectl get pods -o wide
kubectl describe nodes
kubectl describe pod POD_NAME
```

**Observations:**
* Allocatable: CPU `4`, memory `1904216Ki` (~1.81 GiB), pods `110`
* Labels: `kubernetes.io/arch=amd64`, `kubernetes.io/os=linux`, `node-role.kubernetes.io/control-plane=`
* Taints: `<none>`, so pods scheduled without tolerations on this single node.
* Both replicas (100m CPU, 128Mi memory requests each) landed on the same node.
* *(Add your own observation here.)*

### Pod scaling vs node group scaling
* **Replica scaling:** changes the number of Pods inside existing capacity; takes seconds.
* **Node group scaling:** changes EC2 worker count (via ASG / Cluster Autoscaler / Karpenter); takes minutes.

### Requests exceeding capacity
If total requests exceed a node's allocatable resources, the scheduler leaves the Pod `Pending` (`FailedScheduling: Insufficient cpu/memory`) until capacity frees up or a node is added.

### Reserving nodes with labels/taints
Taint the node group (`kubectl taint nodes NODE key=value:NoSchedule`); only Pods with a matching toleration plus a nodeSelector/affinity for the label will land there.

---

## 4. Troubleshooting Note
* **Problem:** Pod stuck in `Pending`.
* **Evidence:**
```text
Warning  FailedScheduling  12s  default-scheduler  0/1 nodes are available: 1 Insufficient cpu.
```
* **Root cause:** Sum of CPU requests exceeds the node's allocatable CPU.
* **Fix:** Lower the pod's CPU requests, or increase node group desired size / enable an autoscaler.
* **Verification:** `kubectl get pods -w` shows Pending → ContainerCreating → Running.

---

## 5. Cost & Cleanup Plan
* No AWS resources were created (design-only), so no EC2 cost.
* If a real node group is created: EC2 + EBS charges apply, EKS control plane is billed separately, and NAT Gateway/public IPv4/data transfer add more. Get budget approval first.
* Cleanup: delete the node group, then check for leftover resources (ENIs, EBS volumes, NAT Gateway, load balancers).
* Local cleanup:
```bash
kubectl delete -f node-capacity-demo.yaml
kubectl get pods
```

---

## 6. Proof of Work
* `01-pod-placement-local-cluster.png`: pod placement (`get pods -o wide`)
* `02-node-allocatable-capacity.png`: allocatable capacity and requests
* `03-node-labels-and-taints.png`: labels and taints
* Design diagram / this README
