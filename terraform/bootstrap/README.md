# Bootstrap — Terraform remote state backend

Creates the resource that every environment's `backend.tf` depends on:

- **S3 bucket** `sufra-terraform-state-<account_id>` — versioned, encrypted,
  private. State locking uses S3 **native lockfiles** (`use_lockfile = true`),
  so no DynamoDB table is required.

> S3 bucket names are **global across all AWS accounts**, so the name includes
> the account ID to avoid collisions. Update the default in `variables.tf` and
> every `environments/*/backend.tf` if your account ID differs.

This is the **chicken-and-egg** step: the remote backend can't store its own
state, so this config uses **local state** and is run once, manually.

## Usage

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

After this succeeds, the bucket exists and you can `terraform init` any
environment (`environments/dev`, `staging`, `production`).

## Handling the local state file

After apply, this directory holds a local `terraform.tfstate`. Two options:

1. **Migrate it into the bucket it just created** (recommended):
   add a `backend "s3"` block here with `key = "bootstrap/terraform.tfstate"`,
   then `terraform init -migrate-state`.
2. **Leave it local** and store it somewhere safe. Note: it is gitignored by
   default — do not commit secrets.

## Optional: GitHub Actions CI role

This config can also create the GitHub OIDC provider and an IAM role the CI
pipeline assumes (no static keys). Enable it:

```bash
terraform apply \
  -var="create_github_oidc=true" \
  -var="github_owner=<org>" \
  -var="github_repo=sufra-infrastructure"
```

Then set the `github_ci_role_arn` output as the repo **variable** `AWS_ROLE_ARN`
(Settings → Secrets and variables → Actions → Variables). The CI workflows skip
their AWS jobs until that variable is set. The default attached policy is
`AdministratorAccess` — tighten it via `ci_role_policy_arn` for real accounts.

## Names must match

`state_bucket_name` here must match the `bucket` value hard-coded in every
`environments/*/backend.tf`. If you change it, update those too.

> The state bucket has `prevent_destroy = true`. To intentionally tear it down,
> remove that lifecycle block first.
