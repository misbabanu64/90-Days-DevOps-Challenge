# Day 26: Deploy & Connect to AWS RDS PostgreSQL

## Executive Summary
On Day 26 of the 90 Days DevOps Challenge, an Amazon Relational Database Service (Amazon RDS) PostgreSQL database was deployed within a customized Virtual Private Cloud (VPC) network architecture. Secure, isolated communication was established from an Amazon EC2 application jump host to the RDS instance using security group chaining. The workflow included testing database connectivity, executing SQL DDL/DML transactions, generating a manual DB snapshot, and validating snapshot restoration. All active billable resources were cleaned up following task completion to preserve cloud credit balance.

---

## Architecture & Security Design

```
+-----------------------------------------------------------------------------------+
| AWS Default VPC                                                                   |
|                                                                                   |
|  +-----------------------------+         +-------------------------------------+  |
|  | EC2 Instance (Jump Host)    |         | RDS PostgreSQL Instance             |  |
|  | Name: day26-ec2-app         |         | Name: day26-postgres-db             |  |
|  | Security Group: app-sg      | ------> | Security Group: db-sg               |  |
|  | Inbound: Port 22 (SSH)      | Port    | Inbound: Port 5432 (PostgreSQL)     |  |
|  | Source: 0.0.0.0/0           | 5432    | Source: sg-xxxx (app-sg ONLY)       |  |
|  | Public IP: Yes              |         | Public Access: No (Private)         |  |
|  +-----------------------------+         +-------------------------------------+  |
|                                                                                   |
|  DB Subnet Group: day26-db-subnet-group (spans 2 Availability Zones)              |
+-----------------------------------------------------------------------------------+
```

### Security & Isolation Principles:
1. **Private Access Control**: The RDS instance was launched with `Publicly Accessible: No`. It has no public IP address, eliminating exposure to internet-based scanning or attacks.
2. **Least Privilege Security Group Rule**: Port 5432 on `db-sg` is not opened to an IP range or subnet CIDR; it explicitly references the Security Group ID of `app-sg`. Only traffic originating from instances assigned to `app-sg` can establish a TCP handshake on port 5432.
3. **Multi-AZ Network Readiness**: A DB Subnet Group (`day26-db-subnet-group`) was created encompassing subnets across two distinct Availability Zones to satisfy RDS high-availability placement prerequisites.

---

## Lab Implementation Details

### Task A: Network & Security Group Provisioning
- **DB Subnet Group**: Created `day26-db-subnet-group` within the default VPC utilizing 2 subnets across separate Availability Zones.
- **Application Security Group (`app-sg`)**:
  - Inbound rule: SSH (Port 22), Source: `0.0.0.0/0` (allowing EC2 Instance Connect browser-based console access).
  - Outbound rule: Default allow all traffic.
- **Database Security Group (`db-sg`)**:
  - Inbound rule: PostgreSQL (Port 5432), Source: `app-sg` Security Group ID.
  - Outbound rule: Default allow all.

### Task B: RDS PostgreSQL Database Provisioning
- **Engine**: PostgreSQL (Free Tier compatible template).
- **Instance Identifier**: `day26-postgres-db`
- **Instance Class**: `db.t3.micro` / `db.t4g.micro`
- **Storage**: 20 GB General Purpose SSD (gp3).
- **Network Configuration**:
  - Virtual Private Cloud: Default VPC
  - DB Subnet Group: `day26-db-subnet-group`
  - Public Access: `No`
  - VPC Security Group: `db-sg`

### Task C: EC2 Setup & SQL Verification
1. Connected to `day26-ec2-app` using AWS EC2 Instance Connect.
2. Installed PostgreSQL client package:
   ```bash
   sudo apt-get update -y && sudo apt-get install -y postgresql-client
   ```
3. Connected securely across the private VPC network to the RDS database endpoint:
   ```bash
   psql -h day26-postgres-db.c58ec2s0eqpx.ap-southeast-2.rds.amazonaws.com -p 5432 -U postgres -d postgres
   ```
4. Executed SQL test statements:
   ```sql
   -- Create a table for validation
   CREATE TABLE lab_notes (
       id SERIAL PRIMARY KEY,
       note TEXT NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Insert test data
   INSERT INTO lab_notes (note)
   VALUES ('Day 26 RDS connection test');

   -- Verify data retrieval
   SELECT id, note, created_at FROM lab_notes;
   ```
5. Confirmed that records were stored and retrieved as expected.

### Task D: Manual Snapshot & Restore Validation
1. **Snapshot Creation**:
   - Initiated a manual snapshot named `day26-db-snapshot` from `day26-postgres-db`.
   - Verified that the snapshot transitioned to the `Available` state.
2. **Restoration Verification**:
   - Executed a snapshot restore with target identifier `day26-postgres-db-restored`.
   - Attached `day26-db-subnet-group` and applied `db-sg` to confirm end-to-end disaster recovery and deployment repeatability.

### Task E: Clean-Up & Cost Management
To maintain zero unauthorized costs and adhere strictly to AWS Free Tier boundaries:
- Terminated EC2 instance `day26-ec2-app`.
- Deleted both restored database (`day26-postgres-db-restored`) and primary database (`day26-postgres-db`) with final snapshots bypassed.
- Deleted manual snapshot `day26-db-snapshot`.
- Verified AWS Billing dashboard: DB Instances count = 0, Manual Snapshots count = 0, with remaining credit balance intact ($159.99 USD) and $20 database completion activity reward claimed.

---

## Lab Artifacts & Verification Screenshots

| File Name | Description |
| :--- | :--- |
| `01-rds-config.png` | RDS PostgreSQL database configuration summary, endpoint details, and VPC attachment. |
| `02-db-sg.png` | Security Group rule configuration showing Port 5432 allowed strictly from `app-sg`. |
| `03-sql-test.png` | EC2 terminal output displaying `psql` connection, table creation, record insert, and `SELECT` output. |
| `04.png` | Successful snapshot creation and restore lifecycle execution verification. |

---

## Key Learnings & Troubleshooting
- **Security Group Chaining**: Learned that referencing a source Security Group ID instead of CIDR IP blocks provides dynamic, resilient, and zero-trust internal network access control within an AWS VPC.
- **EC2 Instance Connect SSH Prerequisite**: Browser-based EC2 Instance Connect requires proper inbound SSH access (Port 22) to resolve browser handshake failures (`152.x.x.x` client restriction fixed by allowing EC2 connect ranges / anywhere).
- **RDS Multi-AZ Requirements**: Understood that RDS Subnet Groups strictly mandate inclusion of subnets in at least two separate Availability Zones, even when running single-AZ deployments.
