variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "aws_region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally-unique name for the Terraform state bucket. Must match the bucket in each environment's backend.tf."
  type        = string
  default     = "sufra-terraform-state"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking. Must match each environment's backend.tf."
  type        = string
  default     = "sufra-terraform-locks"
}

# --- GitHub Actions OIDC (CI/CD) -----------------------------------------
variable "create_github_oidc" {
  description = "Create the GitHub OIDC provider and CI role for the Actions pipeline."
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "GitHub org/user that owns the repo (e.g. sufra)."
  type        = string
  default     = null
}

variable "github_repo" {
  description = "Repository name the CI role is allowed to assume from (e.g. sufra-infrastructure)."
  type        = string
  default     = null
}

variable "github_subject_claims" {
  description = "Allowed `sub` claim patterns. Defaults to any branch/environment of the repo."
  type        = list(string)
  default     = null
}

variable "ci_role_policy_arn" {
  description = "Managed policy attached to the CI role. AdministratorAccess by default; tighten for production use."
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
