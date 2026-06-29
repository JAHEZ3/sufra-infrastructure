variable "project" {
  description = "Project name, used for naming and tagging."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)."
  type        = string
}

variable "vpc_id" {
  description = "VPC the ALB and its security group live in (from the vpc module)."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB (from the vpc module)."
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal (private) rather than internet-facing."
  type        = bool
  default     = false
}

variable "ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB on HTTP/HTTPS."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener (from the acm module). If null, only HTTP is created."
  type        = string
  default     = null
}

variable "additional_certificate_arns" {
  description = "Extra ACM certificate ARNs to attach to the HTTPS listener (SNI)."
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  description = "SSL/TLS security policy for the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP (80) to HTTPS (443). Requires certificate_arn."
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from accidental deletion."
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Connection idle timeout in seconds."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
