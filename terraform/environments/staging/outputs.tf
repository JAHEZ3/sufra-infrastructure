# --- Networking -----------------------------------------------------------
output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

# --- EKS ------------------------------------------------------------------
output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN (for IRSA)."
  value       = module.eks.oidc_provider_arn
}

output "alb_controller_role_arn" {
  description = "IRSA role ARN for the AWS Load Balancer Controller service account."
  value       = module.alb_controller.role_arn
}

# --- ECR ------------------------------------------------------------------
output "ecr_repository_urls" {
  description = "ECR repository URLs."
  value       = module.ecr.repository_urls
}

# --- Edge -----------------------------------------------------------------
output "alb_dns_name" {
  description = "ALB DNS name."
  value       = module.alb.alb_dns_name
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN."
  value       = module.waf.web_acl_arn
}

# --- Data -----------------------------------------------------------------
output "rds_endpoint" {
  description = "RDS connection endpoint."
  value       = module.rds.endpoint
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN for the RDS master password."
  value       = module.rds.master_user_secret_arn
}

output "redis_primary_endpoint" {
  description = "ElastiCache primary endpoint."
  value       = module.elasticache.primary_endpoint_address
}

# --- Storage / secrets ----------------------------------------------------
output "assets_bucket" {
  description = "S3 assets bucket name."
  value       = module.s3.bucket_id
}

output "app_secret_arns" {
  description = "Application secret ARNs."
  value       = module.secrets.secret_arns
}

# --- DNS (only when enabled) ----------------------------------------------
output "route53_name_servers" {
  description = "Name servers to set at the registrar (when enable_dns = true)."
  value       = var.enable_dns ? module.route53[0].name_servers : null
}
