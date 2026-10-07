# 05. DynamoDB & RDS – Database Services

AWS has two main managed database styles:

| | **DynamoDB** | **RDS** |
|---|---|---|
| Type | NoSQL (key-value + document) | Relational (SQL) |
| Schema | Flexible, only the key is fixed | Fixed tables, columns, relations |
| Scaling | Automatic, horizontal, almost unlimited | Mostly vertical (bigger instance) + read replicas |
| Servers | **Serverless**: no instances to manage | You choose a **DB instance** size |
| Query | By key (GetItem / Query), no joins | Full SQL: joins, transactions, reports |
| Latency | Single-digit milliseconds at any scale | Depends on instance, query and indexes |
| Best for | Huge scale, simple access patterns | Complex queries, existing SQL apps |

---

# Part A – DynamoDB

## NoSQL

**NoSQL** = "not only SQL". Data is **not** stored in fixed tables joined by relations.
DynamoDB is a **fully managed, serverless key-value and document database**:

- No servers, patching or storage to manage. Data is copied across 3 AZs automatically.
- Scales to millions of requests per second.
- **Design for your queries first** (access patterns). There are no joins. Related data is often kept together in one table ("single-table design").

## Tables

A **table** is a collection of items. Create one with only its **primary key** and a **capacity mode**:

| Capacity mode | How you pay | Good for |
|---|---|---|
| **On-demand** (default) | Per read/write request | New or unpredictable traffic |
| **Provisioned** (+ auto scaling) | Per RCU/WCU per hour | Steady, predictable traffic (cheaper) |

Extra table features: **Global tables** (multi-region, active-active), **TTL** (auto-delete old items), **Streams** (change feed → Lambda), **PITR** backups (restore to any second in the last 35 days), **DAX** (in-memory cache).

## Items

An **item** is one record (like a row). It's a set of attributes, and each item can have **different attributes**.

- Max item size: **400 KB**.
- Every item **must have the primary key** attributes.

```json
{
  "UserId":    "u#1001",
  "OrderDate": "2026-10-07T21:30:00Z",
  "Total":     499.0,
  "Status":    "SHIPPED",
  "Items":     [ { "sku": "BOOK-42", "qty": 1 } ],
  "Gift":      true
}
```

## Attributes

An **attribute** is one name/value field of an item (like a column, but per item).

| Kind | DynamoDB types |
|---|---|
| Scalar | String `S`, Number `N`, Binary `B`, Boolean `BOOL`, Null `NULL` |
| Document | List `L`, Map `M` (nested JSON-like) |
| Set | String set `SS`, Number set `NS`, Binary set `BS` |

## Partition key

The **partition key (PK, "hash key")** is the main key. DynamoDB **hashes** it to decide which internal partition stores the item.

- **Simple primary key** = partition key only. It must be **unique** per item.
- Choose a key with **many different values** that are used evenly (e.g. `UserId`, `OrderId`). This avoids "hot partitions". A bad key would be `Status` or `Country`.

## Sort key

The **sort key (SK, "range key")** is the optional second part of the key.

- **Composite primary key** = partition key + sort key. The **pair** must be unique.
- Items with the same PK are stored together, **sorted by SK**, so you can query ranges:
  `UserId = "u#1001" AND OrderDate BETWEEN "2026-01" AND "2026-12"`.
- Use **secondary indexes** to query by other attributes:
  - **GSI** (Global Secondary Index): different PK + SK. Can be added at any time.
  - **LSI** (Local Secondary Index): same PK, different SK. Must be created with the table.

```text
Table: Orders      PK = UserId        SK = OrderDate
┌──────────┬──────────────────────┬────────┬─────────┐
│ UserId   │ OrderDate            │ Total  │ Status  │
├──────────┼──────────────────────┼────────┼─────────┤
│ u#1001   │ 2026-09-01T10:00:00Z │ 120.0  │ DONE    │  ┐ same partition,
│ u#1001   │ 2026-10-07T21:30:00Z │ 499.0  │ SHIPPED │  ┘ sorted by date
│ u#2002   │ 2026-10-05T08:15:00Z │  75.5  │ NEW     │
└──────────┴──────────────────────┴────────┴─────────┘
```

```bash
aws dynamodb create-table --table-name Orders \
  --attribute-definitions AttributeName=UserId,AttributeType=S AttributeName=OrderDate,AttributeType=S \
  --key-schema AttributeName=UserId,KeyType=HASH AttributeName=OrderDate,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST

aws dynamodb query --table-name Orders \
  --key-condition-expression "UserId = :u" \
  --expression-attribute-values '{":u":{"S":"u#1001"}}'
```

## DynamoDB use cases

- Shopping carts, user profiles, sessions (fast key lookups).
- Gaming leaderboards and player state.
- IoT and time-series events (with TTL to expire old data).
- Serverless backends: API Gateway + Lambda + DynamoDB.
- High-traffic apps with spiky load (on-demand mode).
- **Terraform state locking table** (the older S3 backend `dynamodb_table` option).

```hcl
resource "aws_dynamodb_table" "orders" {
  name         = "Orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"
  range_key    = "OrderDate"

  attribute {
    name = "UserId"
    type = "S"
  }
  attribute {
    name = "OrderDate"
    type = "S"
  }

  point_in_time_recovery { enabled = true }
}
```

---

# Part B – RDS

## Relational database

A **relational database** stores data in **tables (rows + columns)** with a fixed **schema**, linked by **primary keys and foreign keys**. You query it with **SQL**, and it supports **ACID transactions**.

**Amazon RDS** (Relational Database Service) is **managed** relational databases. AWS handles the hardware, OS, DB installation, patching, backups, failover and monitoring. You handle the schema, queries, indexes and users.

```sql
SELECT u.name, o.total
FROM   users u
JOIN   orders o ON o.user_id = u.id
WHERE  o.created_at >= '2026-10-01';
```

## Supported engines

| Engine | Notes |
|---|---|
| **Amazon Aurora** (MySQL- and PostgreSQL-compatible) | AWS cloud-native engine. Storage auto-grows to 128 TiB with 6 copies in 3 AZs, up to 15 low-lag replicas, Serverless v2 option |
| **PostgreSQL** | Open source, very popular |
| **MySQL** | Open source |
| **MariaDB** | MySQL fork, open source |
| **Oracle** | License included or BYOL |
| **Microsoft SQL Server** | Express / Web / Standard / Enterprise |
| **IBM Db2** | BYOL or via Marketplace |

## DB instances

A **DB instance** is the managed database server that runs one engine.

- **Instance class**: CPU and RAM, e.g. `db.t4g.micro` (burstable), `db.m7g.large` (general), `db.r7g.xlarge` (memory-optimized).
- **Storage**: `gp3` (general SSD) or `io2` (provisioned IOPS). Storage autoscaling can grow it automatically.
- Lives in a **DB subnet group**: private subnets in 2+ AZs of your VPC.
- You connect with an **endpoint** (DNS name) + port, e.g. `mydb.abc123.ap-south-1.rds.amazonaws.com:5432`.
- **No SSH/OS access**. Settings go in **parameter groups** and **option groups**.
- Maintenance window for patches. Stop/start (it auto-starts again after 7 days).

## Security

| Layer | How |
|---|---|
| **Network** | Put it in **private subnets**, set "publicly accessible" to **No**, Security Group allows the DB port only from the app SG |
| **Authentication** | Master user + DB users. Master password stored in **AWS Secrets Manager** (RDS can manage and rotate it). **IAM database authentication** (MySQL/PostgreSQL) |
| **Encryption at rest** | KMS. Must be turned on at creation, and it covers storage, backups, snapshots and replicas |
| **Encryption in transit** | SSL/TLS (e.g. `rds.force_ssl=1` for PostgreSQL) |
| **Access control** | IAM policies for *managing* RDS (create/delete/modify). SQL `GRANT`s for *data* |
| **Monitoring / audit** | CloudWatch, Enhanced Monitoring, Performance Insights / Database Insights, DB logs, CloudTrail |

## Backups

| Type | Details |
|---|---|
| **Automated backups** | Daily snapshot + transaction logs. Retention **1–35 days**. **Point-in-time restore** to any second in that window (always to a new instance) |
| **Manual snapshots** | Made by you, kept until you delete them. Can be copied and shared to other regions/accounts |
| **AWS Backup** | Central backup plans across services |

Restoring always creates a **new DB instance** with a new endpoint.

## Multi-AZ

**Multi-AZ** = **high availability**. RDS keeps a **standby copy in another AZ** with **synchronous** replication.

```text
            App ──► endpoint (DNS) ──► Primary (AZ-a)
                                         │  synchronous replication
                                         ▼
                                       Standby (AZ-b)   ← not readable (instance deployment)
On failure / maintenance: DNS automatically switches to the standby (about 60–120 s)
```

- Automatic failover (hardware failure, AZ outage, patching, instance resize).
- The **standby cannot serve reads** in a classic Multi-AZ *instance* deployment.
- A **Multi-AZ DB cluster** (MySQL/PostgreSQL) has **2 readable standbys** and faster failover.
- About 2× the cost. Use it for production.

## Read replicas

**Read replicas** = **scale reads**. They are copies that use **asynchronous** replication.

- Up to **15** per source (MySQL, MariaDB, PostgreSQL; Oracle and SQL Server have lower limits). Aurora: up to 15 replicas sharing the same storage.
- Each has its **own endpoint**. Send reporting and read-heavy traffic there.
- Can be in the **same region or another region** (good for DR and nearby reads).
- A replica can be **promoted** to a standalone DB (manual).
- Replication is async, so reads may be slightly behind ("replica lag").

| | Multi-AZ | Read replica |
|---|---|---|
| Goal | Availability / failover | Read scaling (and DR) |
| Replication | Synchronous | Asynchronous |
| Readable? | No (instance) / Yes (cluster) | Yes |
| Failover | Automatic | Manual promote |

## RDS use cases

- Web and mobile app backends that need SQL and transactions (e-commerce orders, payments).
- ERP, CRM and CMS apps (WordPress → MySQL).
- Moving on-premises Oracle / SQL Server / MySQL to the cloud with little code change.
- Reporting and BI dashboards on read replicas.
- SaaS apps with relational data and strong consistency needs.

```hcl
resource "aws_db_instance" "app" {
  identifier                  = "session18-postgres"
  engine                      = "postgres"
  engine_version              = "17"
  instance_class              = "db.t4g.micro"
  allocated_storage           = 20
  storage_type                = "gp3"
  storage_encrypted           = true
  username                    = "appadmin"
  manage_master_user_password = true # password kept in Secrets Manager
  db_subnet_group_name        = "private-db-subnets"
  vpc_security_group_ids      = ["sg-0123456789abcdef0"]
  publicly_accessible         = false
  multi_az                    = true
  backup_retention_period     = 7
  deletion_protection         = true
  skip_final_snapshot         = false
}
```

---

## Which one to choose?

```text
Need joins, complex SQL, strict relational schema, existing SQL app?  ──► RDS / Aurora
Simple key lookups, massive scale, spiky traffic, serverless, ms latency? ──► DynamoDB
```

## Summary

- **DynamoDB**: serverless NoSQL. **Tables → items → attributes**, accessed by a **partition key** (+ optional **sort key**). Scales automatically.
- **RDS**: managed SQL on **DB instances** with 7 **engines** (incl. Aurora). Secure it with private subnets, SGs, KMS, TLS and Secrets Manager.
- **Backups** (automated 1–35 days + snapshots), **Multi-AZ** for availability, **read replicas** for read scaling.
