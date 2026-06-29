variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "create_eks_cluster_role" {
  description = "Create the IAM role assumed by the EKS control plane."
  type        = bool
  default     = true
}

variable "create_eks_node_role" {
  description = "Create the IAM role assumed by EKS worker nodes."
  type        = bool
  default     = true
}

variable "node_additional_policy_arns" {
  description = "Extra managed policy ARNs to attach to the EKS node role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
