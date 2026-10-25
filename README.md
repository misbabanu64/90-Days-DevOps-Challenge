# Day 21: Kubernetes Security, RBAC & Troubleshooting

**DevOps Winter Arc — 90 Days Challenge**

## Overview

This hands-on project focuses on Kubernetes security, Role-Based Access Control (RBAC), ServiceAccounts, Pod Security Standards, and troubleshooting broken Deployments using an existing Kind cluster.

## Objectives

- Implement least-privilege access using RBAC.
- Verify permissions using `kubectl auth can-i`.
- Enforce Restricted Pod Security Standards.
- Configure secure, non-root Pods.
- Troubleshoot and fix three broken Deployments.

## 1. RBAC and ServiceAccount

- Created a dedicated `viewer` ServiceAccount in the `secure` namespace.
- Configured a Role and RoleBinding for read-only Pod access.
- Verified allowed and denied actions using `kubectl auth can-i`.
- Confirmed that reading Pods is allowed while deleting Pods is denied.

## 2. Pod Security and Hardening

Configured the Restricted Pod Security Standard for the `secure` namespace.

Security settings included:

- `runAsNonRoot: true`
- `runAsUser: 10001`
- `allowPrivilegeEscalation: false`
- `readOnlyRootFilesystem: true`
- `capabilities.drop: ["ALL"]`
- `seccompProfile: RuntimeDefault`

Tested the policy by attempting to create a root-based Pod.

## 3. Deployment Troubleshooting

| Deployment | Issue | Root Cause | Resolution |
|---|---|---|---|
| `broken1` | ImagePullBackOff | Invalid image tag | Updated to a valid image |
| `broken2` | CrashLoopBackOff | Container command exited with code 1 | Updated to a long-running command |
| `broken3` | Pending | Excessive memory request of 64Gi | Reduced memory request |

## 4. Evidence and Screenshots

### RBAC Permission Verification

Verified that the `viewer` ServiceAccount can read Pods but cannot delete them.

![RBAC authorization check](eviden/1-rbac-auth-check.png)

### Restricted Pod Security

Screenshot showing the root-based Pod rejection under the Restricted Pod Security policy.

![Pod security rejection](eviden/2-pod-security-rejected.png)

### All Pods Running

Screenshot showing the repaired Deployments and their Pods running successfully.

![All Pods Running](eviden/3-all-pods-running.png)

## 5. Troubleshooting Commands

```bash
kubectl get deployments,pods -n lab
kubectl describe pod <pod-name> -n lab
kubectl logs <pod-name> -n lab --previous
kubectl get events -n lab --sort-by=.lastTimestamp
```

Verify RBAC permissions:

```bash
kubectl auth can-i get pods -n secure \
  --as=system:serviceaccount:secure:viewer

kubectl auth can-i delete pods -n secure \
  --as=system:serviceaccount:secure:viewer
```

**Debugging workflow:** `get → describe → logs → events → exec`

## Key Learnings

- Kubernetes RBAC and least-privilege security
- ServiceAccounts, Roles, and RoleBindings
- Pod Security Standards and securityContext
- Deployment troubleshooting and recovery
- Reading Kubernetes Events and container logs
- Verifying permissions and application status

## Technologies Used

Kubernetes | Kind | kubectl | YAML | Linux | Git | GitHub

---

**Challenge:** DevOps Winter Arc — Day 21 of 90  
**Focus:** Kubernetes Security, RBAC & Troubleshooting

