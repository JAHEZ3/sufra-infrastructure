variable "project" {
  description = "Project name."
  type        = string
  default     = "sufra"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

# --- Networking -----------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ)."
  type        = list(string)
  default     = ["10.10.0.0/24", "10.10.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (one per AZ)."
  type        = list(string)
  default     = ["10.10.10.0/24", "10.10.11.0/24"]
}

# --- Environment behavior toggles ----------------------------------------
variable "single_nat_gateway" {
  description = "Use one NAT gateway (cheaper) instead of one per AZ (HA)."
  type        = bool
  default     = true
}

variable "s3_force_destroy" {
  description = "Allow destroying a non-empty assets bucket."
  type        = bool
  default     = true
}

variable "db_multi_az" {
  description = "Deploy RDS with a multi-AZ standby."
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Protect RDS from accidental deletion."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip the RDS final snapshot on destroy."
  type        = bool
  default     = true
}

variable "cache_num_nodes" {
  description = "Number of ElastiCache nodes (primary + replicas)."
  type        = number
  default     = 2
}

# --- DNS / TLS ------------------------------------------------------------
variable "enable_dns" {
  description = "Provision Route53 zone, ACM certificate, HTTPS, and alias records. Requires a real, delegated domain."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name used for Route53 + ACM when enable_dns is true."
  type        = string
  default     = "dev.sufra.com"
}

# --- EKS ------------------------------------------------------------------
variable "cluster_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "node_groups" {
  description = "EKS managed node group definitions."
  type = map(object({
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    desired_size   = number
    min_size       = number
    max_size       = number
    disk_size      = optional(number, 20)
    labels         = optional(map(string), {})
  }))
  default = {
    general = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3
    }
  }
}

# --- ECR ------------------------------------------------------------------
variable "ecr_repositories" {
  description = "ECR repositories to create."
  type        = list(string)
  default     = ["api", "web", "worker"]
}

# --- RDS ------------------------------------------------------------------
variable "db_engine_version" {
  description = "Postgres engine version."
  type        = string
  default     = "16.3"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "sufra"
}

# --- ElastiCache ----------------------------------------------------------
variable "cache_node_type" {
  description = "ElastiCache node type."
  type        = string
  default     = "cache.t3.micro"
}

# --- Observability --------------------------------------------------------
variable "alarm_email_endpoints" {
  description = "Emails to receive CloudWatch alarm notifications."
  type        = list(string)
  default     = []
}
