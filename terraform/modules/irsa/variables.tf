variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "name" {
  description = "Short logical name for the role (e.g. alb-controller, external-dns)."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster IAM OIDC provider (from the eks module)."
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the cluster OIDC issuer without the https:// prefix (from the eks module)."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account."
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Kubernetes service account name allowed to assume this role."
  type        = string
}

variable "policy_arns" {
  description = "Existing IAM policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "inline_policy_json" {
  description = "Optional JSON for a customer-managed policy created and attached to the role."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
