# EKS Teardown & Cost Cleanup Checklist (Day 37)

Safety Rule: EKS cluster delete karne par uske attached resources automatic delete nahi hote. Extra billing se bachne ke liye ye order follow karein:

1. [ ] Kubernetes Services Cleanup:
   Command: kubectl delete svc --all
   Purpose: Active AWS Load Balancers (ALB/NLB) ko release karta hai ($0.0225/hr + LCU charges).

2. [ ] Managed Node Groups Deletion:
   Command: aws eks delete-nodegroup --cluster-name winter-arc-eks-dev --nodegroup-name <nodegroup_name> --region ap-southeast-2
   Purpose: Underlying EC2 instances ko terminate karta hai taaki compute cost stop ho sake.

3. [ ] EKS Cluster Teardown:
   Command: aws eks delete-cluster --name winter-arc-eks-dev --region ap-southeast-2
   Purpose: EKS Control Plane hourly charge ($0.10/hr) stop karta hai.

4. [ ] NAT Gateways & Elastic IPs (EIPs):
   Purpose: NAT Gateways ko delete karke EIPs release karein (har active NAT Gateway aur unused IPv4 charge generate karta hai).

5. [ ] Persistent Volumes (EBS):
   Purpose: Unattached EBS volumes check karein aur terminate karein.

6. [ ] Custom VPC & Security Groups:
   Purpose: Network dependencies clear hone ke baad VPC delete karein.
