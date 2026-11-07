# EKS Cluster Setup Plan & Access Architecture

## 1. IAM vs Kubernetes RBAC (Access Model)
AWS IAM and Kubernetes RBAC operate as distinct authorization boundaries:
- AWS IAM controls entry at the cloud perimeter, authenticating who the identity is (Users, Roles, or SSO) and granting permission to interact with AWS EKS management APIs (such as cluster creation or updating kubeconfig).
- Kubernetes RBAC operates inside the Kubernetes control plane, authorizing what an authenticated identity can execute across cluster objects (such as listing Pods, managing Namespaces, or applying Deployments).
- Integration: EKS leverages native Access Entries (and the legacy aws-auth ConfigMap) to map AWS IAM ARNs directly to internal Kubernetes RBAC roles and cluster role bindings.

## 2. Cluster Specification Plan
- Cluster Name: winter-arc-eks-dev
- Target Region: ap-southeast-2 (Sydney)
- Kubernetes Version: 1.30
- Worker Node Model: Managed Node Group (2x t3.medium EC2 instances)

## 3. Network & Subnet Topology
- VPC CIDR: 10.0.0.0/16
- Public Subnets (for ALB & NAT Gateways):
  - ap-southeast-2a: 10.0.1.0/24
  - ap-southeast-2b: 10.0.2.0/24
- Private Subnets (for Worker Nodes & Pods):
  - ap-southeast-2a: 10.0.10.0/24
  - ap-southeast-2b: 10.0.20.0/24

## 4. API Endpoint Access
- Mode: Public and Private
- Rationale: Allows remote administrative access via kubectl over the internet through TLS, while keeping worker node traffic strictly contained within the private VPC network.
