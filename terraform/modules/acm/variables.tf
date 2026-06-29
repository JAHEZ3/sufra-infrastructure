variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the certificate (e.g. sufra.com)."
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional SANs for the certificate (e.g. [\"*.sufra.com\"])."
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Certificate validation method: DNS (recommended) or EMAIL."
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "validation_method must be DNS or EMAIL."
  }
}

variable "zone_id" {
  description = "Route53 hosted zone ID for DNS validation. Required when validation_method is DNS and create_validation_records is true."
  type        = string
  default     = null
}

variable "create_validation_records" {
  description = "Whether this module should create the Route53 validation records and wait for issuance."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
