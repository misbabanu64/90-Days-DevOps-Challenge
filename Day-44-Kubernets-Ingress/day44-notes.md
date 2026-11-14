# Day 44 - Kubernetes Ingress Notes

## 1. Host/Path Routing Table for shop.example.test

| Host              | Path | pathType | Backend Service | Port |
|-------------------|------|----------|-----------------|------|
| shop.example.test | /    | Prefix   | frontend        | 80   |
| shop.example.test | /api | Prefix   | backend         | 8080 |

Note: /api is listed before / so the more specific path matches first.

If the backend Service has no ready endpoints, the controller has nowhere to send the request, so the user gets a 502/503 error.

## 2. Ingress vs Ingress Controller

- Ingress: a Kubernetes resource (YAML) that only defines the routing rules, like host and path.
- Ingress Controller: the program (like NGINX) that watches Ingress resources and actually routes the traffic.
- An Ingress alone does nothing. Without a controller, no traffic is routed.
- IngressClass: tells which controller should handle which Ingress.

## 3. Troubleshooting Notes

### 404 Not Found
- Check the Host header matches the host in the Ingress.
- Check the path and pathType.
- Check the backend Service name is correct.

### 502 / 503 Errors
- Check the Service port matches the Ingress port.
- Check the Service has ready endpoints: kubectl get endpoints SERVICE_NAME
- Check the Pods are healthy and Ready.
- Check controller-to-backend connectivity.

### TLS Warning
- Check the certificate is valid and not expired.
- Check the certificate hostname matches the host.
- Check the Secret name and namespace are correct (example: shop-tls).
- Never commit private keys or TLS Secrets to a public repository.

## 4. TLS Design (design only, not applied)

Add this under spec in day44-ingress.yaml:

  tls:
  - hosts:
    - shop.example.test
    secretName: shop-tls

- The certificate and private key are stored in a Kubernetes Secret named shop-tls (type kubernetes.io/tls), in the same namespace as the Ingress.
- The Ingress only references the Secret name. The controller reads it and uses it for HTTPS.
- Client to Ingress: HTTPS (encrypted). TLS terminates at the controller.
- Ingress to backend: usually plain HTTP inside the cluster, unless the design requires HTTPS to the backend too.
- For a real domain: a DNS record must point to the controller address, and a valid certificate for that hostname is needed.
- Never commit private keys or TLS Secrets to a public repository.

## 5. Status
Ingress not applied: no controller and no frontend/backend Services in cluster. Design only.

## 6. Why Service is the stable backend
Pod IPs change when Pods restart or scale. A Service gives one fixed address and load balances only to ready Pods.

## 7. Interview Quick Check
- Host-based routing: routes by hostname (shop.example.test). Path-based routing: routes by URL path (/api, /).
- Where TLS can terminate: at the Ingress controller or load balancer (common), or at the backend Pods.
- Gateway API: the newer Kubernetes API for traffic routing. It is more expressive than Ingress and separates roles (infrastructure team manages Gateways, app teams manage Routes).
