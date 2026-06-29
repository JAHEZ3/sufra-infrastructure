variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.30"
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane (from the iam module)."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the EKS worker nodes (from the iam module)."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the control plane ENIs and node groups (usually private subnets)."
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the EKS API server is reachable from the public internet."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the EKS API server is reachable from within the VPC."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "Control plane log types to send to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "node_groups" {
  description = "Map of managed node group definitions."
  type = map(object({
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND") # ON_DEMAND or SPOT
    desired_size   = number
    min_size       = number
    max_size       = number
    disk_size      = optional(number, 20)
    labels         = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
