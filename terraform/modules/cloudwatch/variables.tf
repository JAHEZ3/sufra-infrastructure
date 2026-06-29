variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

# --- Log groups -----------------------------------------------------------
variable "log_groups" {
  description = <<-EOT
    Map of CloudWatch log groups to create, keyed by a short id.
    Example: { app = { name = "/sufra/dev/app", retention_in_days = 30 } }
  EOT
  type = map(object({
    name              = string
    retention_in_days = optional(number, 30)
    kms_key_id        = optional(string)
  }))
  default = {}
}

# --- SNS alarm topic ------------------------------------------------------
variable "create_sns_topic" {
  description = "Create an SNS topic to receive alarm notifications."
  type        = bool
  default     = true
}

variable "alarm_email_endpoints" {
  description = "Email addresses to subscribe to the alarm SNS topic."
  type        = list(string)
  default     = []
}

variable "existing_sns_topic_arn" {
  description = "Use an existing SNS topic instead of creating one. Takes precedence over create_sns_topic."
  type        = string
  default     = null
}

# --- Metric alarms --------------------------------------------------------
variable "metric_alarms" {
  description = <<-EOT
    Map of metric alarms to create, keyed by a short id.
    Example:
      {
        rds_cpu = {
          namespace           = "AWS/RDS"
          metric_name         = "CPUUtilization"
          statistic           = "Average"
          comparison_operator = "GreaterThanThreshold"
          threshold           = 80
          period              = 300
          evaluation_periods  = 2
          dimensions          = { DBInstanceIdentifier = "sufra-dev-db" }
        }
      }
  EOT
  type = map(object({
    namespace           = string
    metric_name         = string
    statistic           = optional(string, "Average")
    comparison_operator = string
    threshold           = number
    period              = optional(number, 300)
    evaluation_periods  = optional(number, 1)
    treat_missing_data  = optional(string, "missing")
    description         = optional(string, "")
    dimensions          = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
