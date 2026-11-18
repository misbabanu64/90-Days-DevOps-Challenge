# Day 48: Kubernetes Production — RBAC & Security

## Goal
Understand how Kubernetes controls access to cluster resources using Authentication, Authorization, and Admission Control, and implement a least-privilege, namespace-scoped read-only ServiceAccount[cite: 1].

---

## Core Concepts
* **Authentication:** Identifies who is making the API request[cite: 1].
* **Authorization (RBAC):** Decides whether the authenticated requester is permitted to perform the requested action[cite: 1].
* **Admission Control:** Intercepts, validates, or mutates requests before objects are persisted in etcd[cite: 1].
* **ServiceAccount:** An identity used by Pods and workloads when interacting with the Kubernetes API server[cite: 1].

---

## Deliverables

### 1. RBAC Manifest (`day48-rbac.yaml`)
Created a dedicated `day48-lab` namespace, a `pod-viewer` ServiceAccount, a read-only `pod-reader` Role (`get`, `list`, `watch` on `pods`), and bound them using `pod-reader-binding`[cite: 1].

### 2. Role vs ClusterRole & Bindings
| Component | Scope | Purpose |
| :--- | :--- | :--- |
| **Role** | Single Namespace | Defines permissions (API groups, resources, verbs) within one specific namespace[cite: 1]. |
| **ClusterRole** | Cluster-wide | Defines cluster-scoped permissions (e.g., Nodes, PersistentVolumes) or reusable rules across namespaces[cite: 1]. |
| **RoleBinding** | Single Namespace | Grants permissions defined in a Role or ClusterRole to a user/ServiceAccount within one namespace[cite: 1]. |
| **ClusterRoleBinding** | Cluster-wide | Grants permissions defined in a ClusterRole across the entire cluster[cite: 1]. |

### 3. Permission Verification (`kubectl auth can-i`) Results & Explanations
| Command | Result | Explanation |
| :--- | :---: | :--- |
| `kubectl auth can-i list pods -n day48-lab --as=system:serviceaccount:day48-lab:pod-viewer` | **yes**[cite: 2] | Allowed because `pod-reader` grants the `list` verb on `pods` in `day48-lab`[cite: 1]. |
| `kubectl auth can-i get pods -n day48-lab --as=system:serviceaccount:day48-lab:pod-viewer` | **yes**[cite: 2] | Allowed because `pod-reader` grants the `get` verb on `pods` in `day48-lab`[cite: 1]. |
| `kubectl auth can-i delete pods -n day48-lab --as=system:serviceaccount:day48-lab:pod-viewer` | **no**[cite: 2] | Denied because `delete` is not included in the Role's allowed verbs (least privilege)[cite: 1]. |
| `kubectl auth can-i list secrets -n day48-lab --as=system:serviceaccount:day48-lab:pod-viewer` | **no**[cite: 2] | Denied because access is restricted strictly to `pods`, protecting sensitive `secrets`[cite: 1]. |
| `kubectl auth can-i list pods -n default --as=system:serviceaccount:day48-lab:pod-viewer` | **no**[cite: 2] | Denied because `RoleBinding` is namespace-scoped to `day48-lab` and does not apply to `default`[cite: 1]. |

### 4. Workload ServiceAccount Inspection
* **Inspected Pod:** `coredns-6f6b679f8f-b9pxz` (in `kube-system` namespace)
* **ServiceAccount Name:** `coredns` (inspected safely using `jsonpath='{.spec.serviceAccountName}'` without exposing tokens or secrets)[cite: 2].

### 5. Least-Privilege Security Recommendations
1. **Use Dedicated ServiceAccounts:** Create a separate ServiceAccount for each application workload instead of using the namespace `default` ServiceAccount[cite: 2].
2. **Prefer Namespace-Scoped RBAC:** Use `Role` and `RoleBinding` instead of `ClusterRole` and `ClusterRoleBinding` whenever cluster-wide access is unnecessary[cite: 2].
3. **Avoid Wildcards (`*`) and `cluster-admin`:** Grant only the exact API groups, resources, and verbs (`get`, `list`) required by the workload[cite: 1, 2].

---

## Evidence Screenshots
1. `screenshots/01_role_rolebinding_sa_created.png` — Creation of Namespace, ServiceAccount, Role, and RoleBinding[cite: 1, 2].
2. `screenshots/02_can_i_read_allowed.png` — Verification of allowed `get` and `list` pod permissions[cite: 1, 2].
3. `screenshots/03_can_i_delete_secrets_denied.png` — Verification of denied `delete` pod, `list` secrets, and cross-namespace actions[cite: 1, 2].
4. `screenshots/04_clusterrole_clusterrolebinding_inspection.png` — Inspection of cluster-level roles and bindings[cite: 2].
5. `screenshots/05_workload_serviceaccount_name.png` — Safe inspection of workload ServiceAccount name (`coredns`)[cite: 2].

---

## Interview Q&A
1. **What is Kubernetes RBAC?**
   Role-Based Access Control (RBAC) regulates access to Kubernetes API resources based on the roles of individual users or ServiceAccounts[cite: 1].
2. **Role vs ClusterRole?**
   A `Role` sets permissions within a specific namespace, whereas a `ClusterRole` defines permissions across the entire cluster or for non-namespaced resources[cite: 1].
3. **RoleBinding vs ClusterRoleBinding?**
   A `RoleBinding` grants permissions within a single namespace, while a `ClusterRoleBinding` grants permissions across all namespaces in the cluster[cite: 1].
4. **What is a ServiceAccount?**
   An identity assigned to Pods so processes running inside containers can authenticate with the Kubernetes API server[cite: 1].
5. **Explain least privilege.**
   The security principle of granting an identity only the minimum permissions necessary to perform its intended function and nothing more[cite: 1].
6. **Name common RBAC verbs.**
   `get`, `list`, `watch`, `create`, `update`, `patch`, and `delete`[cite: 1].
7. **Does RBAC support explicit deny rules?**
   No. Kubernetes RBAC is purely additive—anything not explicitly allowed by a Role/ClusterRole is denied by default[cite: 1].
