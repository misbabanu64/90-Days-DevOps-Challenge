# Day-24 / 90 — AWS Week Day 2: S3 + CloudFront

**Focus:** S3 · Private bucket · Versioning · CloudFront · HTTPS · Caching  
**Level:** Beginner-friendly  
**Cost goal:** Avoid unnecessary charges

---

## 🎯 Today's Goal

Understand how S3 stores website files and how CloudFront can deliver them over HTTPS while the S3 bucket stays **private**.

> Scope: Day 22 (AWS overview) and Day 23 (IAM) are not repeated here.

---

## 🧠 Key Concepts

| Concept | Meaning |
|---|---|
| **S3 Bucket** | Globally unique, named container for objects (HTML, CSS, images) |
| **Object** | A file in S3, identified by an object key |
| **Block Public Access** | Settings that prevent unintended public exposure (keep ON) |
| **Versioning** | Keeps multiple versions so overwrites/deletes can be recovered |
| **CloudFront** | CDN that caches content at edge locations, serves over HTTPS |
| **OAC (Origin Access Control)** | Lets CloudFront access a private S3 origin via bucket policy |
| **Invalidation** | Removes cached content before normal expiry (charges may apply) |

---

## 🏗️ Architecture

```
Visitor -- HTTPS --> CloudFront
                         |
                  signed request (OAC)
                         v
                  Private S3 bucket
                  Block Public Access ON

Direct S3 URL -> 403 Access Denied (expected)
```

**Why doesn't a portfolio bucket need to be public?**  
CloudFront accesses the bucket on the visitor's behalf using OAC, so only CloudFront can read the files. This keeps content safe from accidental exposure and still gives users fast HTTPS delivery.

---

## 📁 Local Project

```
day24-site/
├── index.html   # "Hello from AWS Week."
└── error.html   # page-not-found message
```

---

## 🧪 Commands Used / Learned

```bash
# Identity & config check
aws sts get-caller-identity
aws configure list

# Create private bucket
BUCKET=YOUR-UNIQUE-BUCKET-NAME
aws s3 mb s3://$BUCKET --region ap-south-1

# Block all public access
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Enable versioning + upload site
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled
aws s3 sync ./day24-site s3://$BUCKET
aws s3 ls s3://$BUCKET

# Verify
aws s3api get-public-access-block --bucket "$BUCKET"
aws s3api get-bucket-versioning --bucket "$BUCKET"
aws s3api list-object-versions --bucket "$BUCKET"

# CloudFront (only if a distribution was created)
aws cloudfront list-distributions
aws cloudfront get-distribution --id YOUR_DISTRIBUTION_ID
```

---

## ☁️ CloudFront Setup Notes

- Origin: **S3 bucket** (not the S3 static website endpoint)
- Attach an **OAC** and apply the bucket policy CloudFront generates for that distribution
- Default root object: `index.html`
- Viewer protocol: **Redirect HTTP to HTTPS**
- Wait for deployment, then test the CloudFront domain
- Direct S3 URL should still return **403** — do **not** make the bucket public to "fix" it

---

## 🧹 Cleanup

- Versioned bucket: delete **all object versions and delete markers**, not just current objects
- CloudFront: disable → delete the distribution (not instant)
- Keep checking billing until all resources are gone

---

## ✅ Completion Checklist

- [ ] Can explain S3, objects, versioning, CloudFront, OAC and caching
- [ ] Created a simple local static website
- [ ] (If AWS used) Kept bucket private and enabled versioning
- [ ] Reviewed costs and cleaned up created resources
- [ ] Did not expose credentials or upload sensitive data

---

## 💬 Interview Q&A

1. **What is S3?** Object storage for files/data organised as objects inside buckets.
2. **What does versioning do?** Keeps multiple object versions to recover from overwrites or deletes.
3. **Why keep Block Public Access on?** Reduces the risk of accidentally exposing bucket content.
4. **What is CloudFront?** A CDN that caches content at edge locations and serves it over HTTPS.
5. **What is OAC?** Lets a CloudFront distribution access a private S3 origin.
6. **Why should direct S3 return 403?** The bucket is private; the site is meant to be accessed via CloudFront.
7. **What is invalidation?** A request to remove cached content before it naturally expires.
8. **What must be removed from a versioned bucket before deleting it?** All object versions and delete markers, not just current objects.

---

## 📸 Proof of Work

- Local HTML page
- S3 Block Public Access + versioning settings *(if bucket created)*
- CloudFront HTTPS page + direct S3 403 *(if distribution created)*

> Account IDs and emails hidden in screenshots.

---

## 📝 Key Takeaways

- Private S3 + CloudFront (with OAC) is the secure way to serve static sites.
- A budget alert is **not** a spending cap — always clean up.
- Versioned buckets need versions and delete markers removed before deletion.
