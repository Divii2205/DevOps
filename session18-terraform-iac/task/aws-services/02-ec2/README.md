# 02. EC2 – Elastic Compute Cloud (Compute)

## What is EC2?

**Amazon EC2** gives you **virtual servers ("instances") in the cloud**. You choose the CPU, memory, storage, OS and network. You can start one in about a minute and stop it when you are done.

- You pay **per second** (Linux, minimum 60 s) while the instance is running.
- You control the OS (root/admin access), unlike managed services.
- An instance runs in **one Availability Zone (AZ)** inside a **VPC subnet**.

```text
                 Region (ap-south-1)
  ┌───────────────────────────────────────────────────┐
  │ VPC 10.0.0.0/16                                   │
  │  ┌─────────── AZ ap-south-1a ───────────┐         │
  │  │ Public subnet 10.0.1.0/24            │         │
  │  │  ┌──────────────────────────────┐    │         │
  │  │  │ EC2 instance (t3.micro)      │    │         │
  │  │  │  AMI: Amazon Linux 2023      │    │         │
  │  │  │  Security Group: allow 22,80 │    │         │
  │  │  │  EBS root volume gp3 8 GiB   │    │         │
  │  │  │  Private IP 10.0.1.25        │    │         │
  │  │  │  Public IP 13.x.x.x          │    │         │
  │  │  └──────────────────────────────┘    │         │
  │  └──────────────────────────────────────┘         │
  └───────────────────────────────────────────────────┘
```

---

## AMI (Amazon Machine Image)

An **AMI** is the **template** used to start an instance: OS + pre-installed software + settings + block device mapping.

| Source | Examples |
|---|---|
| AWS provided | Amazon Linux 2023, Ubuntu, Windows Server, RHEL, Debian |
| AWS Marketplace | Ready-made images from vendors (some cost extra) |
| Community | Public AMIs shared by others (check them before use) |
| Your own (custom) | Made from your configured instance (`create-image`) or with EC2 Image Builder / Packer |

- AMIs are **regional**. Copy them to use in another region.
- An AMI ID looks like `ami-0abcd1234ef567890`.

## Instance types

The **instance type** sets the hardware: vCPU, memory, network and storage.
Name format: **family + generation + options . size**, e.g. `t3.micro`, `m7g.large`, `c7i.2xlarge`.

| Family | Optimized for | Examples | Use for |
|---|---|---|---|
| **T** (burstable) | Cheap, CPU credits | `t3.micro`, `t4g.small` | Dev/test, small websites |
| **M** (general purpose) | Balanced CPU/RAM | `m7i.large`, `m7g.xlarge` | App servers, backends |
| **C** (compute) | High CPU | `c7i`, `c7g` | Batch, gaming, encoding |
| **R / X** (memory) | Large RAM | `r7i`, `x2idn` | Databases, caches, in-memory analytics |
| **I / D** (storage) | Fast local NVMe | `i4i`, `d3` | NoSQL, data warehouses |
| **P / G / Inf / Trn** (accelerated) | GPU / ML chips | `p5`, `g6`, `inf2`, `trn1` | ML training/inference, graphics |

Letters: `g` = AWS Graviton (ARM, cheaper), `i` = Intel, `a` = AMD, `d` = local NVMe disk, `n` = more networking.

**Pricing options**

| Option | Discount | Good for |
|---|---|---|
| On-Demand | – | Short or unpredictable workloads |
| Savings Plans / Reserved Instances | up to ~72% | Steady 1–3 year usage |
| Spot Instances | up to ~90% | Fault-tolerant jobs (AWS can take them back with 2 minutes' notice) |
| Dedicated Hosts / Instances | – | Licensing or compliance needs |

## Key pairs

A **key pair** = **public key** (AWS puts it on the instance) + **private key** (`.pem`, you keep it). It is used for **SSH login** to Linux, and to decrypt the Windows admin password.

```bash
aws ec2 create-key-pair --key-name demo-key --key-type ed25519 \
  --query KeyMaterial --output text > demo-key.pem
chmod 400 demo-key.pem
ssh -i demo-key.pem ec2-user@<public-ip>
```

- AWS keeps only the public key. **If you lose the `.pem` file, you cannot download it again.**
- Never commit `.pem` files to Git (this is the kind of file the Session 16 CI security check looks for).
- Alternatives with no SSH keys or open port 22: **EC2 Instance Connect** and **SSM Session Manager**.

## Security Groups

A **Security Group (SG)** is a **virtual firewall for the instance** (it is attached to the network interface).

- **Allow rules only.** There are no deny rules.
- **Stateful**: if inbound traffic is allowed, the reply is allowed automatically.
- Default: **all inbound blocked**, all outbound allowed.
- A rule's source can be a CIDR (`203.0.113.10/32`) or **another security group** (for example, "allow 5432 only from the app-server SG").

| Type | Port | Source | Why |
|---|---|---|---|
| SSH | 22 | My IP `/32` | Admin login (never `0.0.0.0/0`) |
| HTTP | 80 | `0.0.0.0/0` | Website |
| HTTPS | 443 | `0.0.0.0/0` | Website |
| PostgreSQL | 5432 | `sg-app` | Only the app tier talks to the DB |

## EBS (Elastic Block Store)

**EBS** = **network disks (block storage)** for EC2. They are like a hard disk that stays even when the instance is stopped.

- A volume lives in **one AZ** and is attached to an instance in the same AZ.
- **Snapshots** are point-in-time backups stored in S3. Use them to copy a volume to another AZ or region, or to make an AMI.
- Can be **encrypted** with KMS (turn on "encryption by default").
- You can grow the size or change the type while the volume is in use (Elastic Volumes).

| Type | Kind | Use |
|---|---|---|
| **gp3** (default) | General SSD, 3,000 IOPS baseline | Most workloads, boot volumes |
| **io2 Block Express** | Provisioned IOPS SSD | Critical databases |
| **st1** | Throughput HDD | Big sequential data, logs |
| **sc1** | Cold HDD | Data you rarely read, lowest cost |

**Instance store** = disk physically on the host. Very fast, but **its data is lost when the instance stops or terminates**.

## Public vs private IP

| | Private IP | Public IP | Elastic IP |
|---|---|---|---|
| Where it works | Inside the VPC only | Internet | Internet |
| Given when | Always (from the subnet CIDR) | If the subnet/launch setting says so | You allocate it and attach it |
| Changes on stop/start? | **No** | **Yes**, a new one each start | **No** (static) |
| Cost | Free | Charged per hour (all public IPv4 since Feb 2024) | Charged per hour |

- A public IP alone is not enough. The subnet also needs a route to an **Internet Gateway**, and the SG must allow the traffic.
- Instances in private subnets reach the internet through a **NAT Gateway** (outbound only).

## Instance lifecycle

```text
            launch
              │
              ▼
          pending ──────────► running ◄─────────── (start)
                                │  │  │
                       reboot   │  │  └── stop / hibernate ──► stopping ──► stopped
                     (same host,│  │                                         │
                      same IPs) │  └── terminate ─► shutting-down ─► terminated
                                ▼
                            rebooting
```

| State | Billed for compute? | Notes |
|---|---|---|
| pending | No | Booting |
| running | **Yes** | Working |
| stopping / stopped | No (EBS still billed) | Public IP released, private IP kept, may move to a new host |
| hibernated | No (EBS billed) | RAM saved to EBS, fast resume |
| rebooting | Yes | Same host, same IPs, RAM cleared |
| terminated | No | Gone. Root EBS deleted by default (`DeleteOnTermination`) |

Extra settings: **User data** (a script that runs on first boot), **termination protection**, **Auto Scaling groups** to keep N healthy instances.

## Common use cases

- Web and application servers (often behind an **Application Load Balancer** + **Auto Scaling**).
- Self-managed databases or software that needs full OS control.
- CI/CD build agents and self-hosted GitHub Actions runners.
- Batch processing / HPC on Spot instances.
- ML training and inference on GPU instances.
- Bastion / jump hosts. Dev and test environments that are stopped at night to save money.
- Lift-and-shift migration of on-premises servers.

## Terraform example

```hcl
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "web" {
  name = "web-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = "demo-key"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = "#!/bin/bash\ndnf install -y nginx && systemctl enable --now nginx"
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }
  tags = { Name = "session18-web" }
}
```

## Summary

- EC2 = virtual servers. **AMI** = what to run, **instance type** = how big.
- Log in with a **key pair** (or SSM). Control traffic with **Security Groups** (stateful, allow-only).
- **EBS** = disks that stay. **Instance store** = fast, temporary disks.
- Private IPs stay. Public IPs change on stop/start unless you use an **Elastic IP**.
- You pay for compute only while the instance is **running**. EBS is billed always.
