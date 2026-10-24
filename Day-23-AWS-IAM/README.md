# 🚀 Day 23: AWS IAM & Access Management

**DevOps Winter Arc — 90 Days Challenge**  
**AWS Week | Day 1: Identity and Access Management (IAM)**

Today, I started learning AWS Identity and Access Management (IAM), focusing on secure access control, permissions, and essential cloud security practices.

My goal was to understand how AWS controls who can access resources and what actions they are allowed to perform.

---

## 🎯 Learning Objectives

- Understand IAM Users, Groups, Roles, and Policies.
- Learn the Principle of Least Privilege.
- Understand the Default Deny model.
- Explore AWS-managed and Customer-managed policies.
- Understand Multi-Factor Authentication (MFA).
- Explore IAM Role trust relationships.
- Design secure access permissions for different teams.
- Maintain AWS account safety and a $0 planned resource spend.

---

## 📚 1. Core IAM Concepts

| Concept | Description |
|---|---|
| IAM Users | Identities for individuals or workloads that may have long-term credentials. |
| IAM Groups | Collections of IAM users that can share common permissions. |
| IAM Roles | Identities that provide temporary credentials when assumed. |
| IAM Policies | JSON documents that define permissions. |
| MFA | Adds an extra verification step to improve account security. |
| Least Privilege | Grants only the permissions required for a task. |
| Default Deny | Requests are denied unless an applicable Allow grants permission. |
| Trust Policy | Defines which entities are allowed to assume a role. |

### 🔐 IAM Policy Structure

An IAM policy commonly contains these elements:

- **Effect:** Allow or Deny an action.
- **Action:** Specifies which operations are permitted or denied.
- **Resource:** Identifies the AWS resource affected.
- **Condition:** Optionally defines conditions under which a permission applies.

**Important:** An explicit Deny overrides an Allow.

---

## 🛡️ 2. AWS Account Security

During today's learning session, I focused on essential AWS account safety practices.

- Confirmed MFA protection for the root account.
- Verified that AWS budget alerts remained active.
- Explored AWS-managed and Customer-managed IAM policies.
- Inspected IAM role trust relationships.
- Avoided launching chargeable AWS resources.
- Followed safe credential-handling practices.

**Security Reminder:** Budget alerts notify you about spending; they do not automatically prevent charges.

---

## 👥 3. Practical Lab — IAM Access Design

I designed a basic access matrix for three teams: Admins, Developers, and Auditors.

| Team | Intended Access | Security Principle |
|---|---|---|
| Admins | Administrative access for designated administrators | Restrict administrative access. |
| Developers | Read-only baseline with scoped access to a designated S3 lab bucket | Avoid unnecessary administrator permissions. |
| Auditors | Read-only access | Inspect resources without modifying them. |

### Why Should Developers Avoid AdministratorAccess?

AdministratorAccess provides broad permissions across AWS services and resources.

Developers should receive only the permissions necessary for their work. Restricting access helps reduce security risks and follows the Principle of Least Privilege.

---

## 📝 4. Sample IAM Policy — Amazon S3

The following example allows reading and uploading objects within a designated S3 bucket.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::YOUR-LAB-BUCKET/*"
    }
  ]
}
```

**Note:** Replace `YOUR-LAB-BUCKET` with the appropriate bucket name before using the policy.

This example grants object-level permissions. It does not grant permission to list the bucket; that requires a separate `s3:ListBucket` permission on the bucket ARN.

This policy is for learning purposes and was not attached to an AWS identity as part of this exercise.

---

## ☁️ 5. IAM Roles vs. Access Keys

AWS services such as EC2 can use IAM roles to obtain temporary credentials.

**Why prefer IAM roles?**

- Avoid storing long-lived access keys on servers.
- Reduce the risk of exposed credentials.
- Grant only the permissions required by the workload.
- Improve credential management and security.

**Best Practice:** Use an appropriately permissioned IAM role for EC2 workloads instead of hardcoding long-lived AWS access keys.

---

## 💰 6. AWS Cost & Safety Checklist

- [x] Verified that budget alerts remained active.
- [x] Maintained a $0 planned AWS resource spend.
- [x] Avoided launching chargeable resources.
- [x] Followed secure credential-handling practices.
- [x] Reviewed essential IAM security concepts.

**Cost goal:** $0 planned resource spend.

---

## 💡 Key Takeaways

Today's learning helped me understand that AWS security is not just about creating users and assigning permissions. It is about designing access carefully, protecting credentials, and giving every identity only the permissions it needs.

I also learned why IAM roles are preferred for AWS workloads and why overly broad permissions can increase security risks.

---

## 🎤 Interview Preparation

**Q1. What is AWS IAM?**  
AWS Identity and Access Management is a service used to manage access to AWS resources securely.

**Q2. What is the Principle of Least Privilege?**  
It means granting only the minimum permissions required to complete a task.

**Q3. What is the difference between an IAM user and an IAM role?**  
An IAM user is an identity that may have long-term credentials, while an IAM role is assumed to obtain temporary credentials.

**Q4. What is a trust policy?**  
A trust policy defines which entities can assume an IAM role.

**Q5. Why should we enable MFA?**  
MFA adds another verification step and improves account security.

**Q6. Why should EC2 use an IAM role?**  
An IAM role provides temporary credentials without requiring long-lived access keys to be stored on the instance.

---

## 🌱 Conclusion

Day 23 helped me strengthen my understanding of AWS IAM, access management, and cloud security fundamentals.

I am continuing my DevOps journey one practical step at a time, with a strong focus on learning, security, and responsible cloud usage.

**One step closer to becoming a Cloud & DevOps Engineer! 🚀**

---

### 🏷️ Tags

`#90DaysOfDevOps` `#DevOps` `#AWS` `#IAM` `#CloudSecurity` `#LearningInPublic`
