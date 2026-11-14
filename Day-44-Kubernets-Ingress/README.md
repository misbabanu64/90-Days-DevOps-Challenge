# Day 44: Kubernetes Ingress and Traffic Management

Part of my [90 Days DevOps Challenge](../README.md). This day covers how HTTP/HTTPS traffic reaches applications inside a Kubernetes cluster through Ingress.

> **Status:** Design and documentation only. The Ingress was **not applied** because the cluster has no Ingress controller and no `frontend`/`backend` Services. No cloud resources were created.

## Objectives

- Understand how Ingress routes traffic to Kubernetes Services
- Differentiate Ingress, Ingress controller and IngressClass
- Design host-based and path-based routing
- Understand TLS termination
- Troubleshoot routing, DNS, TLS and backend errors

## Traffic flow

```
Client -> DNS -> Ingress Controller -> Ingress rule -> Service -> Ready Pods
```

![Traffic flow diagram](Screenshots/4-traffic-flow-diagram.png)

- DNS resolves the hostname to the controller address.
- TLS terminates at the Ingress controller.
- The controller watches Ingress resources and configures routing.
- The Service is the stable backend because Pod IPs change.

## Routing design for `shop.example.test`

| Host | Path | pathType | Backend Service | Port |
|------|------|----------|-----------------|------|
| shop.example.test | `/api` | Prefix | backend | 8080 |
| shop.example.test | `/` | Prefix | frontend | 80 |

The manifest is in [`day44-ingress.yaml`](day44-ingress.yaml) (design only).

## Cluster inspection (read-only)

Environment: local `kind` cluster. Commands used:

```
kubectl get ingress -A
kubectl get ingressclass
kubectl get svc -A
kubectl apply --dry-run=client -f day44-ingress.yaml
```

Result: no Ingress and no IngressClass exist. Only system Services are present. The manifest passed the client-side dry run.

| Inspection output | Manifest validation |
|---|---|
| ![get ingress](Screenshots/1-get-ingress-ingressclass.png) | ![dry run](Screenshots/2-ingress-yaml-dryrun.png) |

## Notes

Detailed notes are in [`day44-notes.md`](day44-notes.md):

- Routing table
- Ingress vs Ingress controller
- Troubleshooting 404, 502/503 and TLS errors
- TLS design using a `shop-tls` Secret
- Interview quick check (including Gateway API)

## Safety

- Used only a local kind cluster. No AWS login, no cloud load balancers.
- No private keys, TLS Secrets or credentials are committed.

## Files

| File | Description |
|------|-------------|
| `day44-ingress.yaml` | Design-only Ingress manifest |
| `day44-notes.md` | Study notes and troubleshooting |
| `Screenshots/` | Inspection output, dry run, traffic-flow diagram |
