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
  description = "VPC the database and its security group live in."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the database (e.g. EKS nodes)."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database."
  type        = list(string)
  default     = []
}

# --- Engine ---------------------------------------------------------------
variable "engine" {
  description = "Database engine (postgres, mysql, ...)."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version."
  type        = string
  default     = "16.3"
}

variable "port" {
  description = "Database port. Defaults to 5432 (postgres) / 3306 (mysql) if null."
  type        = number
  default     = null
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g. postgres16, mysql8.0). If null, no custom group is created."
  type        = string
  default     = null
}

# --- Capacity -------------------------------------------------------------
variable "instance_class" {
  description = "Instance class (e.g. db.t3.micro, db.r6g.large)."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling in GB. Set equal to allocated_storage to disable."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp3, gp2, io1)."
  type        = string
  default     = "gp3"
}

# --- Credentials / database ----------------------------------------------
variable "db_name" {
  description = "Name of the initial database to create."
  type        = string
  default     = null
}

variable "username" {
  description = "Master username."
  type        = string
  default     = "sufra_admin"
}

variable "manage_master_password" {
  description = "Let RDS generate and store the master password in Secrets Manager."
  type        = bool
  default     = true
}

variable "password" {
  description = "Master password. Only used when manage_master_password is false."
  type        = string
  default     = null
  sensitive   = true
}

# --- High availability / durability --------------------------------------
variable "multi_az" {
  description = "Deploy a standby in another AZ for HA."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Encrypt storage at rest."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN for storage encryption. If null, the default RDS key is used."
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "Days to retain automated backups (0 disables backups)."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC), e.g. 03:00-04:00."
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window, e.g. Mon:04:00-Mon:05:00."
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "deletion_protection" {
  description = "Protect the instance from accidental deletion."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy (true is convenient for dev only)."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = false
}

variable "parameters" {
  description = "Custom DB parameters (requires parameter_group_family)."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
