variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "bucket_name" {
  description = "Bucket name. Globally unique. If null, defaults to <project>-<environment>-<suffix>."
  type        = string
  default     = null
}

variable "name_suffix" {
  description = "Suffix used when bucket_name is null (e.g. assets, uploads)."
  type        = string
  default     = "assets"
}

variable "force_destroy" {
  description = "Allow deleting a non-empty bucket on destroy (dev convenience)."
  type        = bool
  default     = false
}

# --- Access ---------------------------------------------------------------
variable "block_public_access" {
  description = "Enable all four S3 Block Public Access settings."
  type        = bool
  default     = true
}

variable "policy_json" {
  description = "Optional bucket policy JSON to attach."
  type        = string
  default     = null
}

# --- Versioning & encryption ---------------------------------------------
variable "versioning_enabled" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm: AES256 or aws:kms."
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "KMS key ARN when sse_algorithm is aws:kms."
  type        = string
  default     = null
}

# --- Lifecycle ------------------------------------------------------------
variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle rules. Each rule may transition or expire objects.
    Example:
      [{
        id                                = "expire-old"
        prefix                            = "logs/"
        enabled                           = true
        expiration_days                   = 90
        noncurrent_version_expiration_days = 30
        transitions                       = [{ days = 30, storage_class = "STANDARD_IA" }]
      }]
  EOT
  type = list(object({
    id                                 = string
    prefix                             = optional(string, "")
    enabled                            = optional(bool, true)
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))
  default = []
}

# --- CORS -----------------------------------------------------------------
variable "cors_rules" {
  description = "List of CORS rules for the bucket."
  type = list(object({
    allowed_methods = list(string)
    allowed_origins = list(string)
    allowed_headers = optional(list(string), ["*"])
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3000)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
