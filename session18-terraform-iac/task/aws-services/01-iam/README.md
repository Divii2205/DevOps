# 01. IAM – Identity and Access Management (Governance)

## What is IAM?

**IAM** is the AWS service that decides **who** can do **what** on **which** AWS resource.

- **Authentication**: who are you? (user name + password, access keys, MFA, roles)
- **Authorization**: what are you allowed to do? (policies)

Key facts:
- IAM is **global**. It is not tied to one region.
- IAM is **free**. You pay only for the resources that users create.
- A new account has one **root user** (the email you signed up with). The root user can do everything, so use it only for a few account-level tasks.

```text
        WHO (principal)              WHAT (action)          WHICH (resource)
  ┌─────────────────────┐        ┌──────────────────┐     ┌──────────────────────┐
  │ User / Group / Role │ ─────► │ s3:GetObject     │ ──► │ arn:aws:s3:::my-bkt/*│
  └─────────────────────┘        └──────────────────┘     └──────────────────────┘
                 ▲  allowed or denied by a POLICY (JSON document)
```

---

## Users

An **IAM user** is one identity for **one person or one application**.

- Can have a **console password** (to log in to the AWS website).
- Can have up to 2 **access keys** (Access Key ID + Secret) for the CLI, SDK and Terraform.
- Has **no permissions** until a policy gives them some.
- Best practice today: for people, prefer **IAM Identity Center (SSO)** with short-lived credentials. Use IAM users only where you really need them.

```bash
aws iam create-user --user-name divya
aws iam create-login-profile --user-name divya --password 'S0me-Str0ng-Pass!' --password-reset-required
aws iam create-access-key --user-name divya
```

## Groups

An **IAM group** is a collection of users. Policies attached to a group apply to **every user in it**.

- Example groups: `Developers`, `Admins`, `ReadOnly`.
- A user can be in many groups (up to 10).
- Groups **cannot** be nested, and a group cannot be used as a principal in a policy.

```bash
aws iam create-group --group-name Developers
aws iam add-user-to-group --group-name Developers --user-name divya
aws iam attach-group-policy --group-name Developers \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

## Roles

An **IAM role** is an identity with permissions but **no password and no long-term keys**.
Someone or something **assumes** the role and gets **temporary credentials** (from AWS STS) that expire.

A role has two parts:
1. **Trust policy**: *who* is allowed to assume the role (a service, another account, a federated user).
2. **Permissions policy**: *what* the role can do.

Common examples:
| Role used by | Example |
|---|---|
| EC2 instance (instance profile) | App on EC2 reads from S3 with no keys stored on the server |
| Lambda function | Execution role to write logs to CloudWatch |
| Another AWS account | Cross-account access |
| GitHub Actions (OIDC) | CI/CD deploys to AWS with no stored secrets |

Trust policy example (EC2 can assume the role):
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
```

## Policies

A **policy** is a JSON document that lists permissions.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOneBucket",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::divii-demo-bucket",
        "arn:aws:s3:::divii-demo-bucket/*"
      ],
      "Condition": { "Bool": { "aws:SecureTransport": "true" } }
    }
  ]
}
```

| Element | Meaning |
|---|---|
| `Effect` | `Allow` or `Deny` |
| `Action` | API calls, e.g. `s3:GetObject`, `ec2:StartInstances` |
| `Resource` | ARN(s) the actions apply to |
| `Condition` | Optional rules (IP range, MFA present, tags, HTTPS only …) |
| `Principal` | Who (only in resource-based and trust policies) |

**Policy types**

| Type | Attached to | Notes |
|---|---|---|
| **AWS managed** | User / group / role | Written by AWS, e.g. `ReadOnlyAccess`, `AmazonS3FullAccess` |
| **Customer managed** | User / group / role | Written by you, reusable, versioned |
| **Inline** | One identity only | Lives and dies with that identity |
| **Resource-based** | A resource (S3 bucket, SQS queue, KMS key) | Has a `Principal` |
| **Permissions boundary** | User / role | Sets the *maximum* permissions an identity can ever get |
| **SCP (Organizations)** | Account / OU | Guardrail for whole accounts |
| **Session policy** | A temporary session | Limits an assumed-role session |

## Permissions

How AWS decides (simplified evaluation logic):

```text
1. Everything starts as DENY (implicit deny).
2. Is there an explicit "Deny" anywhere?          → YES → DENIED (always wins)
3. Do SCPs / permission boundaries allow it?      → NO  → DENIED
4. Does any identity or resource policy "Allow"?  → YES → ALLOWED
5. Otherwise                                      →       DENIED
```

- **Explicit Deny > Allow > implicit Deny.**
- Check permissions with the **IAM Policy Simulator** or **IAM Access Analyzer**.

## Least privilege

Give **only the permissions needed for the job, and nothing more**.

- Start with nothing, then add only the actions you need.
- Limit `Resource` to exact ARNs, not `"*"`.
- Use `Condition` (source IP, MFA, tags, time).
- Use **IAM Access Analyzer** to create a policy from real CloudTrail activity and to find unused access.
- Review and remove unused users, keys and roles regularly ("last accessed" information).

Bad vs good:
```json
{ "Effect": "Allow", "Action": "s3:*", "Resource": "*" }
```
```json
{ "Effect": "Allow", "Action": "s3:PutObject", "Resource": "arn:aws:s3:::app-uploads/*" }
```

## IAM best practices

1. **Lock away the root user**: turn on MFA, delete root access keys, and use root only for the tasks that need it.
2. **Turn on MFA** for all human users.
3. **Use temporary credentials**: roles and IAM Identity Center instead of long-term access keys.
4. **Use roles for workloads**: EC2 instance profiles, Lambda execution roles, OIDC for CI/CD.
5. **Give permissions to groups**, not to single users.
6. **Least privilege** (see above), plus **permission boundaries** for delegated admins.
7. **Rotate or remove access keys**. Never put keys in code or in Git.
8. **Use a strong password policy**.
9. **Use AWS Organizations + SCPs** for guardrails across many accounts.
10. **Audit**: CloudTrail logs every IAM API call. Use the IAM credential report and Access Analyzer.

## Common use cases

| Use case | IAM feature |
|---|---|
| Team members log in to the console with their own access | Users / Identity Center + groups |
| App on EC2 reads S3 with no keys on the server | Role + instance profile |
| Lambda writes to DynamoDB | Lambda execution role |
| Terraform / CLI on a laptop | User access keys, or better: SSO profile (`aws sso login`) |
| GitHub Actions deploys to AWS | OIDC identity provider + role (no stored secrets) |
| Auditor needs read-only access | `ReadOnlyAccess` / `SecurityAudit` managed policies |
| Vendor account needs access to one bucket | Cross-account role or bucket policy |
| Block whole regions/services for all accounts | Organizations SCPs |

## Terraform example

```hcl
resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_user" "divya" {
  name = "divya"
}

resource "aws_iam_user_group_membership" "divya" {
  user   = aws_iam_user.divya.name
  groups = [aws_iam_group.developers.name]
}

resource "aws_iam_group_policy_attachment" "readonly" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
```

## Summary

- IAM = **who** (users, groups, roles) + **what** (policies) on **which** resource.
- Users are for long-term identities. Roles give **temporary** credentials and are preferred.
- Policies are JSON. An **explicit Deny always wins**.
- Follow **least privilege**, MFA everywhere, no root use, no long-term keys in code.
