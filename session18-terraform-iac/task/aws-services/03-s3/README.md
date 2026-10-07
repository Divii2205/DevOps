# 03. S3 – Simple Storage Service (Storage)

## What is S3?

**Amazon S3** is **object storage**. You store files ("objects") of any type in containers ("buckets") and get them back over HTTPS from anywhere.

- **Very durable**: 99.999999999% (11 nines). Data is copied across at least 3 AZs (for most storage classes).
- **No size limit for the bucket**. One object can be up to **5 TB** (use multipart upload above 100 MB).
- **Pay for what you use**: GB stored per month + requests + data transfer out.
- **Strong read-after-write consistency** for all PUT, LIST and DELETE requests.
- It is **not** a file system or a disk. You can't mount it like EBS. You read and write whole objects through an API.

```text
s3://divii2205-session18-tf-demo/reports/2026/october.pdf
     └──────── bucket ─────────┘ └────────── key ─────────┘
```

---

## Buckets

A **bucket** is the top-level container for objects.

- The name is **globally unique** (across all AWS accounts): 3–63 characters, lowercase letters, numbers, dots and hyphens.
- A bucket is created in **one region** (data stays there unless you replicate it).
- Default limit: 10,000 buckets per account (can be raised).
- **Block Public Access** is **ON by default** for new buckets. Keep it on unless you really need a public bucket.
- **Object Ownership = Bucket owner enforced** (ACLs off) is the default. Control access with policies, not ACLs.

```bash
aws s3 mb s3://divii2205-session18-demo --region ap-south-1
aws s3 ls
```

## Objects

An **object** = **key** (its full name/path) + **data** (the bytes) + **metadata** (+ optional **version ID** and **tags**).

- There are no real folders. `reports/2026/` is just a **prefix** in the key that the console shows like a folder.
- Metadata: system (`Content-Type`, `Last-Modified`, `ETag`) and user-defined (`x-amz-meta-*`).
- **Tags**: up to 10 key/value pairs per object. Used for lifecycle rules, access control and cost.
- **Pre-signed URLs** give someone temporary access to one object without making it public.

```bash
aws s3 cp report.pdf s3://divii2205-session18-demo/reports/2026/report.pdf
aws s3 ls s3://divii2205-session18-demo --recursive
aws s3 presign s3://divii2205-session18-demo/reports/2026/report.pdf --expires-in 3600
aws s3 sync ./website s3://divii2205-session18-demo/site/
```

## Storage classes

Pick the class based on **how often you read the data** and **how fast you need it back**.

| Storage class | Access pattern | Retrieval | Min. storage duration | Typical use |
|---|---|---|---|---|
| **S3 Standard** | Frequent | ms | – | Websites, active app data |
| **S3 Intelligent-Tiering** | Unknown / changing | ms (archive tiers optional) | – | "Don't know" data. AWS moves objects between tiers for you |
| **S3 Express One Zone** | Very frequent, very low latency | single-digit ms | – (1 hour) | ML training, analytics scratch (1 AZ, directory buckets) |
| **S3 Standard-IA** | Infrequent | ms | 30 days | Backups you may need fast |
| **S3 One Zone-IA** | Infrequent, can be re-created | ms | 30 days | Secondary copies (1 AZ only) |
| **S3 Glacier Instant Retrieval** | Rare (about once a quarter) | ms | 90 days | Medical images, news archives |
| **S3 Glacier Flexible Retrieval** | Rare | minutes – 12 h | 90 days | Backups, DR |
| **S3 Glacier Deep Archive** | Almost never | 12 – 48 h | 180 days | Compliance archives (lowest cost) |

The cheaper the storage, the more each retrieval usually costs.

## Versioning

**Versioning** keeps **every version** of an object in the bucket.

- States: **Unversioned** (default) → **Enabled** → **Suspended**. Once enabled, it can never go back to unversioned.
- An overwrite creates a **new version**. A delete only adds a **delete marker**, and the old versions stay, so you can restore them.
- It protects against accidental deletes and overwrites. It is required for **replication**.
- **MFA Delete** can require MFA to delete a version permanently.
- Old versions cost storage. Clean them up with lifecycle rules (`NoncurrentVersionExpiration`).

```bash
aws s3api put-bucket-versioning --bucket divii2205-session18-demo \
  --versioning-configuration Status=Enabled
aws s3api list-object-versions --bucket divii2205-session18-demo
```

## Lifecycle policies

**Lifecycle rules** move or delete objects automatically, based on their **age**, **prefix** or **tags**.

- **Transition** actions: move to a cheaper class (e.g. Standard → Standard-IA after 30 days → Glacier after 90 days).
- **Expiration** actions: delete objects or old versions after N days. Clean up unfinished multipart uploads.

```json
{
  "Rules": [{
    "ID": "logs-archive",
    "Filter": { "Prefix": "logs/" },
    "Status": "Enabled",
    "Transitions": [
      { "Days": 30, "StorageClass": "STANDARD_IA" },
      { "Days": 90, "StorageClass": "GLACIER" }
    ],
    "Expiration": { "Days": 365 },
    "NoncurrentVersionExpiration": { "NoncurrentDays": 30 },
    "AbortIncompleteMultipartUpload": { "DaysAfterInitiation": 7 }
  }]
}
```

## Encryption

| Where | Option | Who manages the key |
|---|---|---|
| **In transit** | HTTPS/TLS (force it with the `aws:SecureTransport` condition) | – |
| **At rest** | **SSE-S3** (AES-256), the **default for all new objects since Jan 2023** | AWS |
| | **SSE-KMS**: AWS KMS key, gives an audit trail in CloudTrail and key policies | You (in KMS) |
| | **DSSE-KMS**: two layers of KMS encryption | You (in KMS) |
| | **SSE-C**: you send the key with every request | You (outside AWS) |
| | **Client-side encryption**: encrypt before upload | You |

With SSE-KMS, turn on **S3 Bucket Keys** to cut KMS request costs.

## Bucket policies

A **bucket policy** is a **resource-based** IAM policy (JSON) attached to the bucket. Use it to:
- give access to **other accounts** or services (CloudFront, ALB logs …)
- **force** HTTPS or encryption
- limit access to a VPC endpoint or an IP range

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::divii2205-session18-demo",
        "arn:aws:s3:::divii2205-session18-demo/*"
      ],
      "Condition": { "Bool": { "aws:SecureTransport": "false" } }
    },
    {
      "Sid": "AllowCloudFrontRead",
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::divii2205-session18-demo/site/*",
      "Condition": { "StringEquals": { "AWS:SourceArn": "arn:aws:cloudfront::123456789012:distribution/EDFDVBD6EXAMPLE" } }
    }
  ]
}
```

Access is decided by **IAM policies + bucket policy + Block Public Access + (old) ACLs** together. An explicit Deny anywhere wins.

## Common use cases

- **Static website hosting** (usually behind CloudFront).
- **Backup and restore, disaster recovery** (with versioning, replication and Glacier).
- **Data lake** for analytics (Athena, Glue, EMR, Redshift Spectrum).
- **App uploads**: images and documents (with pre-signed URLs).
- **Logs** from CloudTrail, ALB and VPC Flow Logs.
- **Build artifacts and Docker layers** for CI/CD.
- **Terraform remote state**: an S3 backend with versioning (S3 native state locking with `use_lockfile = true`).
- **Long-term archive** for compliance (Glacier Deep Archive + Object Lock).

## Terraform example

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "divii2205-session18-demo"
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id
  rule {
    id     = "logs-archive"
    status = "Enabled"
    filter { prefix = "logs/" }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration { days = 365 }
  }
}
```

## Summary

- S3 = object storage: **buckets** (globally unique names, one region) hold **objects** (key + data + metadata).
- Pick a **storage class** by access pattern, and use **lifecycle rules** to move and delete data automatically.
- **Versioning** protects against mistakes. **Encryption** (SSE-S3 by default) and **TLS** protect the data.
- Control access with **IAM + bucket policies + Block Public Access** (on by default).
