# Bootstrap — Terraform remote state backend

Creates the resources that every environment's `backend.tf` depends on:

- **S3 bucket** `sufra-terraform-state` — versioned, encrypted, private
- **DynamoDB table** `sufra-terraform-locks` — state locking

This is the **chicken-and-egg** step: the remote backend can't store its own
state, so this config uses **local state** and is run once, manually.

## Usage

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

After this succeeds, the buckets/table exist and you can `terraform init` any
environment (`environments/dev`, `staging`, `production`).

## Handling the local state file

After apply, this directory holds a local `terraform.tfstate`. Two options:

1. **Migrate it into the bucket it just created** (recommended):
   add a `backend "s3"` block here with `key = "bootstrap/terraform.tfstate"`,
   then `terraform init -migrate-state`.
2. **Leave it local** and store it somewhere safe (it only manages two
   resources). Note: it is gitignored by default — do not commit secrets.

## Optional: GitHub Actions CI role

This config can also create the GitHub OIDC provider and an IAM role the CI
pipeline assumes (no static keys). Enable it:

```bash
terraform apply \
  -var="create_github_oidc=true" \
  -var="github_owner=<org>" \
  -var="github_repo=sufra-infrastructure"
```

Then set the `github_ci_role_arn` output as the repo secret `AWS_ROLE_ARN`.
The default attached policy is `AdministratorAccess` — tighten it via
`ci_role_policy_arn` for real accounts.

## Names must match

`state_bucket_name` and `lock_table_name` here must match the values hard-coded
in every `environments/*/backend.tf`. If you change them, update those too.

> The state bucket has `prevent_destroy = true`. To intentionally tear it down,
> remove that lifecycle block first.
