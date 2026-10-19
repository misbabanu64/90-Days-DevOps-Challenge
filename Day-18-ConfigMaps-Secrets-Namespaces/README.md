# Day 18: ConfigMaps, Secrets & Namespaces

DevOps Winter Arc, 90 Days Challenge, Kubernetes Week 3.

## Overview

Is din ka focus: same Nginx workload ko `dev` aur `prod` namespaces mein alag configuration ke saath chalana.

- Namespaces: `dev` aur `prod`
- ConfigMap `site`: `APP_ENV` aur `index.html` (mounted file)
- Secret `db-secret`: `DB_PASSWORD` (sirf dummy values, lab use)
- Deployment `web`: nginx:1.27, 1 replica, dono namespaces mein same YAML
- Update behavior: mounted file vs environment variable

## Environment

- Windows laptop + WSL Ubuntu
- Kubernetes: kind cluster `day17` (node version v1.31.0)

## Setup Steps

### Task A: Namespaces

```bash
kubectl create namespace dev
kubectl create namespace prod
kubectl get namespaces
```

### Task B: ConfigMaps

```bash
kubectl apply -f configmap-dev.yaml -n dev
kubectl apply -f configmap-prod.yaml -n prod
kubectl get configmap site -n dev
kubectl get configmap site -n prod
```

### Task C: Secrets (dummy values only)

```bash
kubectl create secret generic db-secret --from-literal=password=dev-pass -n dev
kubectl create secret generic db-secret --from-literal=password=prod-pass -n prod
kubectl get secret db-secret -n dev
kubectl get secret db-secret -n prod
```

### Task D: Deployment

```bash
kubectl apply -f deployment.yaml -n dev
kubectl apply -f deployment.yaml -n prod
kubectl get pods -n dev
kubectl get pods -n prod
```

## Task F: Config Update Observations (dev)

### Edit se pehle

```
$ curl http://localhost:8081
<h1>Hello from DEV</h1>
<p>Winter Arc · Day 18</p>

$ kubectl exec -n dev deploy/web -- printenv APP_ENV
dev
```

### Edit ke baad

```
$ curl http://localhost:8081
<h1>Hello from DEV UPDATED</h1>
<p>Winter Arc · Day 18(Updated)</p>

$ kubectl rollout restart deployment/web -n dev
deployment.apps/web restarted

$ kubectl exec -n dev deploy/web -- printenv APP_ENV
dev-v2
```

---

## Interview / Reflection Questions

### 1. What is the difference between a ConfigMap and a Secret?
- **ConfigMap:** Non-sensitive configuration data (jaise environment variables, ports, configuration files) ko plain text mein store karta hai.
- **Secret:** Sensitive credentials (jaise passwords, tokens, API keys) ko store karta hai jo default roop se base64-encoded hote hain[cite: 1, 3].

### 2. Why must referenced ConfigMaps and Secrets exist in the Pod's namespace?
- ConfigMaps aur Secrets namespace-scoped resources hain[cite: 1, 3]. Kubernetes Pod security aur namespace isolation ki wajah se Pod sirf usi namespace ke objects ko reference/mount kar sakta hai jismein woh khud chal raha hai[cite: 1, 3]. Cross-namespace reference allow nahi hota[cite: 3].

### 3. What is the difference between environment variables and mounted files?
- **Environment Variables:** Pod container start hote waqt process environment mein inject hote hain[cite: 3]. Agar source ConfigMap update ho jaye, tab bhi environment variable bina Pod restart/recreate kiye change nahi hota[cite: 3].
- **Mounted Files:** ConfigMap data file system par directory ke taur par mount hota hai[cite: 3]. Jab ConfigMap edit hota hai, toh kubelet mounted files ko automatically update kar deta hai (delay ke baad) bina container restart kiye[cite: 3].

### 4. Why does changing a ConfigMap not update an existing container's environment automatically?
- Linux mein chalte hue running process ke environment variables ko bahar se inject ya dynamically modify nahi kiya ja sakta[cite: 3]. Environment values container launch ke waqt freeze ho jaate hain, isliye update load karne ke liye `rollout restart` zaroori hota hai[cite: 3].

### 5. Why is base64 not sufficient to protect a Secret?
- Base64 sirf ek encoding scheme hai, encryption nahi[cite: 3]. Koi bhi person base64 encoded string ko bina kisi key ya password ke asani se decode kar sakta hai[cite: 3]. Real security ke liye Kubernetes RBAC, KMS-based Encryption at Rest, ya HashiCorp Vault jaise dedicated secrets manager use hone chahiye[cite: 3].

### 6. What can cause CreateContainerConfigError?
- Referenced ConfigMap ya Secret specified namespace mein exist na karta ho[cite: 3].
- Deployment YAML ke andar mention ki gayi `key` ConfigMap ya Secret ke actual keys se match na kar rahi ho[cite: 3].
- Secret/ConfigMap ka naam galat type kiya gaya ho[cite: 3].

### 7. How do namespaces help separate dev and prod resources?
- Same cluster par logical isolation provide karte hain[cite: 1].
- Same manifest / resource names (jaise Deployment name `web`, ConfigMap name `site`) dono environments mein bina kisi naming conflict ke coexist kar sakte hain[cite: 1, 2].
- Per-namespace access control (RBAC), quotas, aur limits set kiye ja sakte hain[cite: 3].
