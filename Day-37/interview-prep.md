# Day 37 Interview Quick-Check (AWS EKS)

1. What is Amazon EKS?
- A managed Kubernetes service provided by AWS that simplifies running Kubernetes clusters without installing and operating the control plane.

2. What does AWS manage in EKS?
- The Kubernetes control plane (API Server, Controller Manager, Scheduler, and etcd database across multiple AZs). The customer still manages worker node compute and application workloads.

3. Where do application Pods run?
- On worker compute instances such as EC2 worker nodes (within managed/self-managed node groups) or on AWS Fargate (serverless compute).

4. What is a managed node group?
- An EC2 auto-scaling group integrated directly with AWS EKS that automates the provisioning, updating, and draining of Kubernetes worker nodes.

5. Difference between AWS IAM and Kubernetes RBAC?
- AWS IAM handles authentication at the AWS boundary (who can invoke AWS APIs). Kubernetes RBAC controls authorization within the cluster (what objects an authenticated user or role can read or modify).

6. Why deploy worker nodes across multiple Availability Zones?
- To ensure high availability, fault tolerance, and resilience against single-AZ outages.

7. Does deleting an EKS cluster remove every related resource?
- No. Separately created resources like load balancers, persistent EBS volumes, NAT Gateways, and Elastic IPs must be manually inspected and deleted to prevent ongoing charges.
