# Day 21: Kubernetes Security, RBAC & Troubleshooting

**DevOps Winter Arc | 90 Days Challenge**

## Overview

This hands-on task focuses on Kubernetes security, Role-Based Access Control (RBAC), ServiceAccounts, Pod Security Standards, and troubleshooting broken Deployments using an existing Kind cluster.

## Objectives

- Configure least-privilege access using RBAC.
- Verify permissions using `kubectl auth can-i`.
- Enforce Restricted Pod Security Standards.
- Run Pods with a hardened security context.
- Troubleshoot and repair broken Deployments.

## 1. RBAC and ServiceAccount

- Created a `viewer` ServiceAccount in the `secure` namespace.
- Configured a Role and RoleBinding for read-only Pod access.
- Verified permissions using `kubectl auth can-i`.
- Confirmed that Pod reading is allowed and Pod deletion is denied.

## 2. Pod Security and Hardening

Enforced the Restricted Pod Security Standard on the `secure` namespace.

Security configurations:

- `runAsNonRoot: true`
- `runAsUser: 10001`
- `allowPrivilegeEscalation: false`
- `readOnlyRootFilesystem: true`
- `capabilities.drop: ["ALL"]`
- `seccompProfile: RuntimeDefault`

Tested that a root-based Pod is rejected by the Restricted policy.

## 3. Deployment Troubleshooting

| Deployment | Symptom | Root Cause | Fix |
|---|---|---|---|
| broken1 | ImagePullBackOff | Invalid image tag | Updated to a valid image |
| broken2 | CrashLoopBackOff | Container command exited with code 1 | Updated to a long-running command |
| broken3 | Pending | Excessive 64Gi memory request | Reduced memory request |

## 4. Evidence and Screenshots

### RBAC Permission Verification

Verified read access and confirmed that Pod deletion is denied.

![RBAC Permission Check](evidence/1-rbac-auth-check.png)

### Restricted Pod Security

Evidence of the root-based Pod being rejected by the Restricted security policy.

![Pod Security Rejection](evidence/2-pod-security-rejected.png)

### All Pods Running

Evidence showing the repaired Deployments and Pods running successfully.

![All Pods Running](evidence/3-all-pods-running.png)

## 5. Troubleshooting Commands

```bash
kubectl get deployments,pods -n lab
kubectl describe pod <pod-name> -n lab
kubectl logs <pod-name> -n lab --previous
kubectl get events -n lab --sort-by=.lastTimestamp
```

### RBAC Verification

```bash
kubectl auth can-i get pods -n secure \
  --as=system:serviceaccount:secure:viewer

kubectl auth can-i delete pods -n secure \
  --as=system:serviceaccount:secure:viewer
```

**Debugging workflow:** `get → describe → logs → events → exec`

## Key Learnings

- Kubernetes RBAC and least privilege
- ServiceAccounts, Roles, and RoleBindings
- Pod Security Standards and securityContext
- Troubleshooting Kubernetes Deployments
- Inspecting Events and container logs
- Verifying permissions and Pod status

## Technologies Used

Kubernetes | Kind | kubectl | YAML | Linux | Git | GitHub

---

**Challenge:** DevOps Winter Arc — Day 21 of 90

**Focus:** Kubernetes Security, RBAC & Troubleshooting
