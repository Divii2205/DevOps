# 04. VPC – Virtual Private Cloud (Networking)

## What is VPC?

A **VPC** is **your own private, isolated network inside AWS**. You choose the IP range, split it into subnets, and decide how traffic flows in and out (routes, gateways, firewalls).

- A VPC belongs to **one region** and spans **all AZs** in that region.
- Each region has a **default VPC** (all subnets public) so you can start quickly. Production setups use a custom VPC.
- The VPC itself is free. You pay for some parts (NAT Gateway, public IPv4, VPC endpoints, traffic).

```text
Region ap-south-1
┌──────────────────────────── VPC 10.0.0.0/16 ─────────────────────────────┐
│                                                                          │
│   ┌──── AZ ap-south-1a ─────────────┐   ┌──── AZ ap-south-1b ──────────┐ │
│   │ Public subnet  10.0.1.0/24      │   │ Public subnet  10.0.2.0/24   │ │
│   │  [ALB]  [NAT Gateway]           │   │  [ALB]                       │ │
│   ├─────────────────────────────────┤   ├──────────────────────────────┤ │
│   │ Private subnet 10.0.11.0/24     │   │ Private subnet 10.0.12.0/24  │ │
│   │  [EC2 app]                      │   │  [EC2 app]                   │ │
│   ├─────────────────────────────────┤   ├──────────────────────────────┤ │
│   │ DB subnet      10.0.21.0/24     │   │ DB subnet      10.0.22.0/24  │ │
│   │  [RDS primary]                  │   │  [RDS standby]               │ │
│   └─────────────────────────────────┘   └──────────────────────────────┘ │
│                                                                          │
│   Public route table : 0.0.0.0/0 → Internet Gateway (igw-…)              │
│   Private route table: 0.0.0.0/0 → NAT Gateway      (nat-…)              │
└──────────────────────────────────┬───────────────────────────────────────┘
                                   │
                           Internet Gateway ─── Internet
```

---

## CIDR

**CIDR** (Classless Inter-Domain Routing) writes an IP range as `address/prefix`.
The prefix tells you how many bits are fixed. **Fewer fixed bits = more addresses.**

| CIDR | Addresses | Example use |
|---|---|---|
| `10.0.0.0/16` | 65,536 | Whole VPC (the largest allowed is `/16`) |
| `10.0.1.0/24` | 256 (251 usable in AWS) | One subnet |
| `10.0.1.0/28` | 16 (11 usable) | The smallest subnet allowed |
| `203.0.113.10/32` | 1 | A single IP (e.g. "my laptop" in an SG rule) |
| `0.0.0.0/0` | All IPv4 | "Anywhere / the internet" |

- Use private ranges (RFC 1918): `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`.
- VPC size: from `/16` down to `/28`. You can add secondary CIDRs, and optionally IPv6 (`/56`).
- **Plan so ranges don't overlap** with other VPCs and your office network. Overlapping VPCs can't be peered.
- AWS **reserves 5 IPs in every subnet**: network address, `.1` (router), `.2` (DNS), `.3` (future use), broadcast.

## Subnets

A **subnet** is a slice of the VPC CIDR that lives in **exactly one AZ**.

- Put resources in subnets: EC2, RDS, Lambda (in VPC), load balancers.
- Spread subnets over **at least 2 AZs** for high availability.
- What makes a subnet "public" or "private" is its **route table**, not a setting on the subnet.

## Route tables

A **route table** is a list of rules: "traffic to *destination* goes to *target*".

- Every VPC has a **main route table**. Each subnet is linked to exactly one route table.
- The **`local`** route (VPC CIDR → local) is always there, so all subnets in a VPC can reach each other.
- The **most specific route wins** (longest prefix match).

| Destination | Target | Meaning |
|---|---|---|
| `10.0.0.0/16` | local | Traffic inside the VPC |
| `0.0.0.0/0` | `igw-…` | Internet (public subnet) |
| `0.0.0.0/0` | `nat-…` | Internet, outbound only (private subnet) |
| `172.31.0.0/16` | `pcx-…` | Peered VPC |
| `pl-… (S3)` | `vpce-…` | S3 through a gateway endpoint (free, private) |

## Internet Gateway

An **Internet Gateway (IGW)** connects the VPC to the internet, **both ways**.

- One IGW per VPC. AWS manages it and it scales automatically. It's free.
- For an instance to be reachable from the internet, all four must be true:
  1. the VPC has an IGW attached
  2. the subnet's route table has `0.0.0.0/0 → igw`
  3. the instance has a **public IP or Elastic IP**
  4. the Security Group and NACL allow the traffic

## NAT Gateway

A **NAT Gateway** lets instances in **private subnets** reach the internet (OS updates, API calls). The internet **cannot start connections back in**.

- It is placed in a **public subnet** and has an **Elastic IP**.
- The private route table has `0.0.0.0/0 → nat-…`.
- It lives in one AZ. For high availability, use **one NAT Gateway per AZ**.
- **It costs money**: per hour + per GB processed. It's often the biggest surprise on a small bill. Use **VPC endpoints** for S3/DynamoDB so that traffic doesn't go through NAT.
- A NAT *instance* (a self-managed EC2) is the older, cheaper but manual option.

## Security Groups

**Security Groups** = a **stateful firewall at the instance / network-interface level**.

- **Allow rules only.** Default: deny all inbound, allow all outbound.
- **Stateful**: reply traffic is allowed automatically.
- All rules are checked together (there is no rule order).
- A rule can point to **another SG**. For example, the DB SG allows `5432` only from the `app-sg`.

## Network ACLs

**Network ACLs (NACLs)** = a **stateless firewall at the subnet level**.

- Have **allow and deny** rules.
- **Stateless**: you must allow return traffic yourself (ephemeral ports `1024-65535`).
- Rules are checked **in number order**. The first match wins, and the final `*` rule denies.
- The default NACL allows everything. A new custom NACL denies everything.
- Good for blocking a bad IP range for a whole subnet.

### Security Group vs NACL

| | Security Group | Network ACL |
|---|---|---|
| Level | Instance / ENI | Subnet |
| Rules | Allow only | Allow **and** Deny |
| State | **Stateful** | **Stateless** |
| Evaluation | All rules | In order, first match |
| Default | Inbound deny, outbound allow | Default NACL: allow all |
| Typical use | Main access control | Extra layer, block IP ranges |

```text
Internet → IGW → Route table → [NACL (subnet)] → [Security Group (instance)] → EC2
```

## Public vs private subnet

| | Public subnet | Private subnet |
|---|---|---|
| Default route | `0.0.0.0/0 → Internet Gateway` | `0.0.0.0/0 → NAT Gateway` (or no internet at all) |
| Reachable from the internet? | Yes (if public IP + SG allow) | **No** |
| Can reach the internet? | Yes | Outbound only, through NAT |
| Put here | Load balancers, NAT Gateway, bastion host | App servers, databases, internal services |

Common pattern: **3 tiers**. Public (ALB) → private app (EC2/ECS/EKS) → private DB (RDS), in 2+ AZs.

## Other useful VPC pieces

| Feature | What it does |
|---|---|
| **VPC Peering** | Private link between 2 VPCs (not transitive) |
| **Transit Gateway** | A hub that connects many VPCs and on-premises networks |
| **VPC Endpoints** | Private access to AWS services: *Gateway* (S3, DynamoDB, free) or *Interface* (PrivateLink) |
| **VPC Flow Logs** | Record IP traffic for troubleshooting and security |
| **Site-to-Site VPN / Direct Connect** | Connect your office or data center |
| **Elastic IP** | Static public IPv4 |

## Terraform example

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "session18-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
```

## Summary

- VPC = your private network in a region. **CIDR** sets its IP range.
- **Subnets** live in one AZ. **Route tables** make them public (→ IGW) or private (→ NAT).
- **IGW** = two-way internet. **NAT Gateway** = outbound only for private subnets, and it costs money.
- **Security Groups** (stateful, instance level) + **NACLs** (stateless, subnet level) = layered firewall.
