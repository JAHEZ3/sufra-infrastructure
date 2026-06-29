variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster IAM OIDC provider (from the eks module)."
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the cluster OIDC issuer without https:// (from the eks module)."
  type        = string
}

variable "namespace" {
  description = "Namespace the controller runs in."
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Service account name used by the AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
