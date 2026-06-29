variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "secrets" {
  description = <<-EOT
    Map of secrets to manage, keyed by a short id. The actual secret value is
    optional: omit `value`/`value_map` to create an empty placeholder that is
    populated out-of-band (recommended for real credentials so they never
    enter Terraform state in plaintext from a literal).

    Example:
      {
        stripe = { description = "Stripe API key", value = var.stripe_key }
        app    = { description = "App config", value_map = { REDIS_URL = "..." } }
        empty  = { description = "Filled by the app later" }
      }
  EOT
  type = map(object({
    description = optional(string, "")
    # Provide exactly one of value / value_map, or neither for a placeholder.
    value     = optional(string)
    value_map = optional(map(string))
  }))
  default = {}

  # value and value_map are mutually exclusive per secret.
  validation {
    condition = alltrue([
      for s in values(var.secrets) : !(s.value != null && s.value_map != null)
    ])
    error_message = "Each secret may set value OR value_map, not both."
  }
}

variable "recovery_window_in_days" {
  description = "Days before a deleted secret is permanently removed (0 forces immediate deletion)."
  type        = number
  default     = 7
}

variable "kms_key_id" {
  description = "KMS key ARN to encrypt secrets. If null, the default aws/secretsmanager key is used."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
