variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "repositories" {
  description = "List of ECR repository names to create (without project prefix)."
  type        = list(string)
  default     = []
}

variable "image_tag_mutability" {
  description = "Tag mutability: MUTABLE or IMMUTABLE."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image vulnerability scanning on push."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for repositories: AES256 or KMS."
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "KMS key ARN to use when encryption_type is KMS."
  type        = string
  default     = null
}

variable "max_image_count" {
  description = "Number of most-recent images to retain via lifecycle policy. Set 0 to disable."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
