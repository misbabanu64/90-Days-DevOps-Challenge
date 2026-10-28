# Day 27: AWS VPC Networking Architecture (DevOps Challenge)

## 1. Overview & Objective
- **Goal:** Understand AWS network traffic flow, subnetting, CIDR notation, and route table mechanics[cite: 1].
- **Region:** Asia Pacific Sydney (`ap-southeast-2`)
- **Scope:** Custom VPC creation, dual-AZ architecture, public/private route scoping, and safe zero-cost resource cleanup[cite: 1, 2].

---

## 2. Key Concepts Learned
- **VPC (Virtual Private Cloud):** Logically isolated virtual network dedicated to an AWS account[cite: 1].
- **CIDR (Classless Inter-Domain Routing):** IP address allocation method (`10.0.0.0/16` gives 65,536 private IPs)[cite: 1].
- **Public Subnet:** A subnet whose associated route table has a default route (`0.0.0.0/0`) targeting an Internet Gateway (IGW)[cite: 1].
- **Private Subnet:** A subnet with no direct path to an IGW, keeping backend instances isolated from inbound internet traffic[cite: 1].
- **Stateful vs Stateless (SG vs NACL):**
  - **Security Group:** Resource-level, stateful firewall (return traffic is automatically allowed)[cite: 1, 3].
  - **NACL:** Subnet-level, stateless filter evaluating numeric rules in order (requires explicit ephemeral port rules for outbound return traffic)[cite: 1, 2, 3].

---

## 3. Network Architecture & CIDR Table
- **VPC CIDR:** `10.0.0.0/16`[cite: 1]

| Subnet Name | Type | Availability Zone | CIDR Block | Route Target |
| :--- | :--- | :--- | :--- | :--- |
| `public-subnet-1a` | Public | `ap-southeast-2a` | `10.0.1.0/24` | `0.0.0.0/0` -> IGW[cite: 1] |
| `public-subnet-1b` | Public | `ap-southeast-2b` | `10.0.2.0/24` | `0.0.0.0/0` -> IGW[cite: 1] |
| `private-subnet-1a` | Private | `ap-southeast-2a` | `10.0.11.0/24` | `10.0.0.0/16` -> Local[cite: 1] |
| `private-subnet-1b` | Private | `ap-southeast-2b` | `10.0.12.0/24` | `10.0.0.0/16` -> Local[cite: 1] |

---

## 4. Route Table Matrix
- **Public Route Table (`public-rt`):**
  - `10.0.0.0/16` -> `local` (VPC internal traffic)[cite: 1]
  - `0.0.0.0/0` -> `day27-igw` (Default route for internet egress/ingress)[cite: 1, 2]
  - Subnet Associations: `public-subnet-1a`, `public-subnet-1b`[cite: 1, 2]

- **Private Route Table (`private-rt`):**
  - `10.0.0.0/16` -> `local` (VPC internal traffic only)[cite: 1]
  - Subnet Associations: `private-subnet-1a`, `private-subnet-1b`[cite: 1, 2]

---

## 5. Cost & Safety Consideration (No-Cost Path)
- **NAT Gateway Warning:** NAT Gateways carry continuous hourly fees and data processing charges[cite: 1].
- **Safety Decision:** Practiced the **No-cost alternative** specified in the lab design by implementing VPC, Subnets, IGW, and Route Tables without deploying paid NAT Gateways or Elastic IPs[cite: 1, 2].
- **Total Lab Spend:** $0.00 (Zero billing impact).

---

## 6. Hands-on Troubleshooting Note
- **Symptom:** Attempting to delete `public-rt` produced the error: *"Route tables have associations and cannot be deleted"*[cite: 12].
- **Root Cause:** Active explicit subnet associations existed between the route table and the lab subnets[cite: 12]. AWS prevents dropping route tables linked to network dependencies[cite: 2, 12].
- **Fix:** Deleted the subnets first to dissociate them cleanly[cite: 2]. Once dependencies were cleared, the route tables deleted without issues[cite: 2, 14].

---

## 7. Safe Cleanup Verification
Completed resource teardown in dependency order[cite: 2, 3]:
1. Detached and deleted custom Internet Gateway (`day27-igw`)[cite: 2].
2. Deleted all custom subnets (`public-subnet-1a/b`, `private-subnet-1a/b`)[cite: 1, 2].
3. Deleted custom Route Tables (`public-rt`, `private-rt`)[cite: 2].
4. Deleted custom VPC (`day27-custom-vpc`)[cite: 2].
5. Verified AWS VPC dashboard to ensure only the default VPC (`172.31.0.0/16`) remains[cite: 2, 4].

---

## 8. Interview Preparation & Answers
- **Q: What makes a subnet public?**  
  **A:** Its route table has a default route pointing to an Internet Gateway (`0.0.0.0/0` -> IGW), combined with public IP addressing and open security rules[cite: 1, 3].
- **Q: NAT Gateway vs Internet Gateway (IGW)?**  
  **A:** An IGW provides two-way internet access for public resources[cite: 1, 3]. A NAT Gateway enables private instances to make outbound internet connections while blocking incoming internet-initiated connections[cite: 1, 3].
- **Q: Security Group vs NACL?**  
  **A:** Security Groups are stateful, applied at the instance ENI level, and support allow rules only[cite: 1, 3]. NACLs are stateless, applied at the subnet boundary, and evaluate numbered allow/deny rules[cite: 1, 3].
- **Q: How can a private instance access S3 without internet routing?**  
  **A:** By creating an S3 Gateway VPC Endpoint and attaching it to the private subnet's route table[cite: 3].
- **Q: Why spread subnets across multiple Availability Zones?**  
  **A:** For high availability and fault tolerance; if one AZ fails, services in another AZ continue operating[cite: 3].
