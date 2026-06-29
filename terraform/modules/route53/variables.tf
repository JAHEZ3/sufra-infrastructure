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
  description = "The hosted zone domain name (e.g. sufra.com)."
  type        = string
}

variable "create_zone" {
  description = "Create the hosted zone. Set false to use an existing zone via existing_zone_id."
  type        = bool
  default     = true
}

variable "existing_zone_id" {
  description = "ID of an existing hosted zone to use when create_zone is false."
  type        = string
  default     = null
}

variable "private_zone" {
  description = "Whether the created hosted zone is private (associated with a VPC)."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID to associate with the zone when private_zone is true."
  type        = string
  default     = null
}

variable "alias_records" {
  description = <<-EOT
    Map of alias (A) records to create, keyed by record name.
    Use for ALB/CloudFront targets. name "" or "@" means the zone apex.
  EOT
  type = map(object({
    name                   = string
    target_dns_name        = string
    target_zone_id         = string
    evaluate_target_health = optional(bool, true)
  }))
  default = {}
}

variable "records" {
  description = <<-EOT
    Map of standard (non-alias) DNS records, keyed by an arbitrary id.
    Example: { txt = { name = "@", type = "TXT", ttl = 300, values = ["v=spf1 -all"] } }
  EOT
  type = map(object({
    name   = string
    type   = string
    ttl    = optional(number, 300)
    values = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
