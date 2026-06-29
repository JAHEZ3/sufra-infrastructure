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
  description = "VPC the cache and its security group live in."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the cache subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the cache (e.g. EKS nodes)."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the cache."
  type        = list(string)
  default     = []
}

# --- Engine ---------------------------------------------------------------
variable "engine" {
  description = "Cache engine (redis or valkey)."
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "Engine version."
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "Node instance type (e.g. cache.t3.micro, cache.r6g.large)."
  type        = string
  default     = "cache.t3.micro"
}

variable "port" {
  description = "Cache port."
  type        = number
  default     = 6379
}

variable "parameter_group_name" {
  description = "Parameter group to use. If null, a family default is chosen by AWS."
  type        = string
  default     = null
}

# --- Topology -------------------------------------------------------------
variable "num_cache_clusters" {
  description = "Number of nodes (primary + replicas) when cluster mode is disabled."
  type        = number
  default     = 2
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover. Requires at least 2 nodes."
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Place replicas in different AZs."
  type        = bool
  default     = true
}

# --- Security -------------------------------------------------------------
variable "at_rest_encryption_enabled" {
  description = "Encrypt data at rest."
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Encrypt data in transit (TLS)."
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "AUTH token (password) for Redis. Requires transit_encryption_enabled. If null, no AUTH is set."
  type        = string
  default     = null
  sensitive   = true
}

variable "kms_key_id" {
  description = "KMS key ARN for at-rest encryption. If null, the default key is used."
  type        = string
  default     = null
}

# --- Maintenance / backups ------------------------------------------------
variable "snapshot_retention_limit" {
  description = "Days to retain automatic snapshots (0 disables)."
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily snapshot window (UTC), e.g. 03:00-05:00."
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly maintenance window, e.g. mon:05:00-mon:07:00."
  type        = string
  default     = "mon:05:00-mon:07:00"
}

variable "apply_immediately" {
  description = "Apply modifications immediately rather than during the maintenance window."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
