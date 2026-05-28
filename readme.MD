# AWS Three-Tier Infrastructure - Terraform + ECS Fargate

A production-grade three-tier web application deployed on AWS using Terraform, containerised with Docker, and delivered via a GitHub Actions CI/CD pipeline.


---

## Architecture

```
Tier 1 — Presentation   Next.js (ECS Fargate)
Tier 2 — Application    Node.js/Express (ECS Fargate)
Tier 3 — Data           RDS MySQL (private subnet)
```

### Infrastructure overview

| Component | Service |
|---|---|
| DNS | Namecheap → Route 53 hosted zone |
| SSL | AWS ACM (auto-renewing) |
| Load balancing | Application Load Balancer (HTTPS) |
| Container orchestration | ECS Fargate (serverless) |
| Container registry | Amazon ECR |
| Database | RDS MySQL 8.0 (db.t3.micro) |
| Networking | VPC, public/private subnets, NAT gateway |
| State management | S3 backend |
| IaC | Terraform (modular) |
| CI/CD | GitHub Actions + self-hosted Docker runner |
| Security scanning | tfsec |
| Email delivery | Resend |

---

## Repository structure

```
.
├── .github/workflows/cicd.yaml   # GitHub Actions pipeline
├── docker-git-runner-setup/      # Self-hosted runner (Dockerfile + entrypoint)
├── module-vpc/                   # VPC, subnets, NAT gateway, security groups
├── module-ecs/                   # ECS cluster, services, ALB, ECR, IAM
├── module-dns/                   # Route 53, ACM certificate, DNS records
├── module-database/              # RDS MySQL instance and subnet group
├── main.tf                       # Root module wiring
├── variable.tf                   # Input variable declarations
├── output.tf                     # Stack outputs
├── backend.tf                    # S3 remote state
└── 01-provider.tf                # AWS provider configuration
```

---

## CI/CD pipeline

Every push to `main` triggers:

1. Checkout → configure AWS credentials
2. `terraform init` → write `terraform.tfvars` from GitHub secret
3. `terraform fmt` → `terraform validate`
4. `tfsec` security scan
5. `terraform plan` → `terraform apply`

The pipeline runs on a self-hosted GitHub Actions runner containerised in Docker, deployed on an EC2 instance.

---

## Prerequisites

- AWS account with appropriate IAM permissions
- Terraform ≥ 1.5
- Docker Desktop
- Domain registered with Namecheap (or any registrar)
- Resend account for email delivery

---

## Deployment

```bash
terraform init
terraform apply -auto-approve
```

After apply, update your domain registrar with the Route 53 nameservers from the output:

```bash
terraform output route53_name_servers
```

---

## Tear down

```bash
terraform destroy -auto-approve
```

---

## Key design decisions

**ECS Fargate over EKS**: Fargate removes node management entirely. No EC2 instances to patch, no node group sizing. AWS handles the underlying compute, and the ALB handles routing — a cleaner fit for a two-service deployment than running a full Kubernetes control plane.

**ACM over Let's Encrypt**: ACM certificates are free, auto-renewing, and natively integrated with the ALB. No cert-manager, no renewal cron jobs.

**Modular Terraform**: each concern (VPC, ECS, DNS, database) lives in its own module with explicit inputs and outputs. Modules are independently testable and reusable across environments.

**Self-hosted runner**: the GitHub Actions runner runs in Docker on an EC2 instance inside the same AWS account, giving the pipeline direct access to AWS APIs without storing long-lived credentials in GitHub beyond the initial IAM key pair.

---

## Author

Kazeem Jimoh
`

<!-- ## This is the architecture for the infrastruture deployment
![Project Architecture](architecture.png)# aws-three-tier-Deploy
# aws-three-tier-Deploy -->
