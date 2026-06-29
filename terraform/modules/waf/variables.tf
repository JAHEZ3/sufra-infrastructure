variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "scope" {
  description = "WAF scope: REGIONAL (ALB/API Gateway) or CLOUDFRONT."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "scope must be REGIONAL or CLOUDFRONT."
  }
}

variable "default_action" {
  description = "Default action when no rule matches: allow or block."
  type        = string
  default     = "allow"

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "default_action must be allow or block."
  }
}

variable "managed_rule_groups" {
  description = <<-EOT
    AWS-managed rule groups to enable (in priority order).
    Example:
      [
        { name = "AWSManagedRulesCommonRuleSet",        priority = 1 },
        { name = "AWSManagedRulesKnownBadInputsRuleSet", priority = 2 },
        { name = "AWSManagedRulesSQLiRuleSet",          priority = 3 }
      ]
  EOT
  type = list(object({
    name            = string
    priority        = number
    vendor_name     = optional(string, "AWS")
    override_action = optional(string, "none") # none | count
  }))
  default = [
    { name = "AWSManagedRulesCommonRuleSet", priority = 1 },
    { name = "AWSManagedRulesKnownBadInputsRuleSet", priority = 2 },
    { name = "AWSManagedRulesAmazonIpReputationList", priority = 3 },
  ]
}

variable "enable_rate_limiting" {
  description = "Enable an IP-based rate limit rule."
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Max requests allowed from a single IP over 5 minutes."
  type        = number
  default     = 2000
}

variable "rate_limit_priority" {
  description = "Rule priority for the rate limit rule."
  type        = number
  default     = 100
}

variable "ip_allow_list" {
  description = "CIDR blocks to always allow (bypasses other rules). Empty disables the rule."
  type        = list(string)
  default     = []
}

variable "ip_block_list" {
  description = "CIDR blocks to always block. Empty disables the rule."
  type        = list(string)
  default     = []
}

variable "associate_resource_arns" {
  description = "ARNs of REGIONAL resources (e.g. ALB) to associate with this Web ACL."
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Enable WAF logging to a CloudWatch log group."
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Retention for the WAF log group."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
