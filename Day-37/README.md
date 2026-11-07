# Day 37: AWS EKS – Architecture & Cluster Setup Plan

## 1. Objective
Gain an end-to-end understanding of Amazon EKS architecture, analyze the AWS-managed vs Customer-managed shared responsibility model, design a production-grade VPC/subnet network across multiple Availability Zones, and construct a risk-free setup and cleanup plan without unapproved cloud expenses.

## 2. Architecture & Shared Responsibility
- **AWS-Managed (Control Plane):** Kubernetes API server, etcd database, Controller Manager, and Kube-Scheduler running across multiple AZs.
- **Customer-Managed (Worker Infrastructure):** EC2 Worker Nodes, Managed Node Groups, VPC networking (subnets, route tables, Internet Gateways), Pods, and Security Groups.
- **Traffic Path:** External Traffic -> Internet Gateway -> Application Load Balancer (Public Subnets) -> Kubernetes Service -> Target Pods (Private Subnets).
- **Architecture File:** Detailed ASCII topology saved in `eks-architecture.txt`.

## 3. IAM Access vs Kubernetes RBAC
- **AWS IAM:** Authenticates cloud identities at the perimeter (who can communicate with AWS EKS endpoints and run AWS CLI commands).
- **Kubernetes RBAC:** Authorizes actions inside the cluster (what pods, namespaces, or secrets an authenticated identity can inspect or modify).
- **Integration:** EKS maps IAM ARNs to internal Kubernetes RBAC groups using EKS Access Entries and cluster role bindings.

## 4. Pre-Flight Verification & Observations
Executed read-only pre-flight commands:
- `aws --version`: AWS CLI v2 installed (`aws-cli/2.31.35`).
- `kubectl version --client`: Kubectl client verified (`v1.37.1`).
- `aws sts get-caller-identity`: Validated credentials state (read-only; verified expired token state without exposing long-lived credentials).
- `aws configure list`: Default region confirmed as `ap-southeast-2`.

## 5. Cost-Awareness & Teardown Checklist
As per Day 37 safety guidelines, actual cluster creation is optional and requires explicit budget approval. In production or active labs, teardown must follow this exact order:
- [ ] Delete all Kubernetes `LoadBalancer` type services (releases AWS ELB/ALB resources).
- [ ] Delete Managed Node Groups (terminates worker EC2 instances).
- [ ] Delete EKS Cluster via CLI/Console (`aws eks delete-cluster`).
- [ ] Delete NAT Gateways and release associated Elastic IPs (EIPs).
- [ ] Terminate orphaned unattached EBS volumes provisioned by dynamic PVCs.
- [ ] Delete custom subnets, route tables, and VPC.

## 6. Deliverables & Screenshots Generated
- `01_eks_architecture_diagram.png`: Network topology, AZ separation, and traffic paths.
- `02_preflight_identity_check.png`: CLI and kubectl version verification with redacted identity.
- `03_cluster_setup_plan.png`: Full cluster specification and IAM vs RBAC breakdown.
- `04_readme_and_cleanup_checklist.png`: Final Day 37 README and teardown checklist.
