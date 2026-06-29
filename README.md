# sufra-infrastructure

Infrastructure-as-Code for the **Sufra** platform, managed with [Terraform](https://www.terraform.io/) on AWS.

## Structure

```
sufra-infrastructure/
│
├── .github/workflows/       # CI/CD: terraform-plan.yml (PRs), terraform-apply.yml (merge)
│
├── terraform/
│   ├── bootstrap/           # One-time: state bucket + lock table + GitHub OIDC CI role
│   │
│   ├── modules/             # Reusable modules
│   │   ├── vpc/  iam/  ecr/  eks/  alb/  acm/  route53/
│   │   └── rds/  elasticache/  s3/  cloudwatch/  waf/  secrets-manager/
│   │
│   └── environments/        # Per-environment root configs (each is runnable)
│       ├── dev/
│       ├── staging/
│       └── production/
│
├── .gitignore
└── README.md
```

Each environment directory is a **self-contained root module** with its own
`backend.tf`, `provider.tf`, `versions.tf`, `variables.tf`, `main.tf`,
`outputs.tf`, and a `terraform.tfvars.example`. The `main.tf` is identical
across environments — only the `.tfvars` values and the state key differ.

## Prerequisites

- Terraform >= 1.5.0
- AWS credentials configured (`aws configure` or environment variables)

## Deploy workflow

### 1. Bootstrap the remote state backend (once per account)

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

Creates the encrypted, versioned S3 bucket (`sufra-terraform-state`) and the
DynamoDB lock table (`sufra-terraform-locks`) referenced by every
environment's `backend.tf`. See `bootstrap/README.md` for details.

### 2. Deploy an environment

```bash
cd terraform/environments/dev          # or staging / production
cp terraform.tfvars.example terraform.tfvars   # edit as needed
terraform init                          # uses the S3 backend from step 1
terraform plan
terraform apply
```

## CI/CD (GitHub Actions)

Two workflows in `.github/workflows/`:

| Workflow | Trigger | Does |
|----------|---------|------|
| `terraform-plan.yml`  | Pull request | `fmt` + `validate` + `plan` for every environment; posts each plan as a PR comment |
| `terraform-apply.yml` | Merge to `main` | `apply` in order **dev → staging → production** |

Authentication uses **GitHub OIDC** — no static AWS keys. Setup:

1. Enable the CI role in bootstrap:
   ```bash
   cd terraform/bootstrap
   terraform apply \
     -var="create_github_oidc=true" \
     -var="github_owner=<org>" \
     -var="github_repo=sufra-infrastructure"
   ```
2. Copy the `github_ci_role_arn` output into the repo secret **`AWS_ROLE_ARN`**.
3. (Optional) set the repo variable **`AWS_REGION`** (defaults to `us-east-1`).
4. In **Settings → Environments**, create `dev`, `staging`, `production` and add
   **required reviewers** to `staging`/`production` to gate those applies.

> The default CI policy is `AdministratorAccess` for convenience. Scope it down
> via the `ci_role_policy_arn` variable before using in a real account.

## Environment differences

| Setting               | dev        | staging    | production         |
|-----------------------|------------|------------|--------------------|
| Availability zones    | 2          | 2          | 3                  |
| NAT gateways          | 1 (shared) | 1 (shared) | 1 per AZ           |
| RDS Multi-AZ          | no         | no         | yes                |
| RDS deletion protect  | no         | yes        | yes                |
| S3 force_destroy      | yes        | no         | no                 |
| EKS nodes             | t3.medium  | t3.large   | m5.large + SPOT    |
| DB instance class     | db.t3.micro| db.t3.small| db.r6g.large       |

## Conventions

- **Modules** are reusable and environment-agnostic; inputs in, outputs out.
- **Environments** wire modules together with environment-specific values.
- All resources are tagged with `Project`, `Environment`, and `ManagedBy`
  via the provider's `default_tags`.
- Secure defaults: encryption at rest, private subnets for data stores,
  security-group-reference ingress, and least-privilege IAM.

## DNS / TLS

Route53 + ACM + HTTPS are gated behind `enable_dns` (default `false`) so the
stack applies without a registered domain. Set `enable_dns = true` and a real,
delegated `domain_name` to provision the hosted zone, certificate, and alias
records. Update your registrar's NS records to the zone's `name_servers`
(an output) to complete delegation.
