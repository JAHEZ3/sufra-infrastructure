# ---------------------------------------------------------------------------
# dev environment: composes the reusable modules into a full stack.
#
# Dependency flow:
#   vpc, iam, ecr, s3  (no deps)
#     -> eks (vpc + iam)
#     -> route53 zone -> acm -> alb -> route53 alias records
#     -> rds, elasticache (vpc + eks SG)
#     -> waf (alb), cloudwatch, secrets-manager
# ---------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# ===========================================================================
# Foundation
# ===========================================================================
module "vpc" {
  source = "../../modules/vpc"

  project              = var.project
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
}

module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment
}

module "ecr" {
  source = "../../modules/ecr"

  project      = var.project
  environment  = var.environment
  repositories = var.ecr_repositories
}

module "s3" {
  source = "../../modules/s3"

  project       = var.project
  environment   = var.environment
  name_suffix   = "assets"
  force_destroy = var.s3_force_destroy
}

# ===========================================================================
# Compute
# ===========================================================================
module "eks" {
  source = "../../modules/eks"

  project          = var.project
  environment      = var.environment
  cluster_version  = var.cluster_version
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn
  subnet_ids       = module.vpc.private_subnet_ids
  node_groups      = var.node_groups
}

# IRSA role for the AWS Load Balancer Controller (install the controller via
# Helm separately and annotate its service account with the role ARN output).
module "alb_controller" {
  source = "../../modules/eks-alb-controller"

  project           = var.project
  environment       = var.environment
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

# ===========================================================================
# DNS + TLS (optional - requires a real, delegated domain)
# ===========================================================================
module "route53" {
  source = "../../modules/route53"
  count  = var.enable_dns ? 1 : 0

  project     = var.project
  environment = var.environment
  domain_name = var.domain_name
  # Alias records are created in module.route53_records to avoid a cycle
  # (zone -> acm -> alb -> alias record).
}

module "acm" {
  source = "../../modules/acm"
  count  = var.enable_dns ? 1 : 0

  project                   = var.project
  environment               = var.environment
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  zone_id                   = module.route53[0].zone_id
}

# ===========================================================================
# Edge
# ===========================================================================
module "alb" {
  source = "../../modules/alb"

  project         = var.project
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  certificate_arn = var.enable_dns ? module.acm[0].certificate_arn : null
}

# Alias records point the domain at the ALB. Reuses the existing zone, so it
# can depend on the ALB without creating a cycle with ACM validation.
module "route53_records" {
  source = "../../modules/route53"
  count  = var.enable_dns ? 1 : 0

  project          = var.project
  environment      = var.environment
  domain_name      = var.domain_name
  create_zone      = false
  existing_zone_id = module.route53[0].zone_id

  alias_records = {
    apex = {
      name            = "@"
      target_dns_name = module.alb.alb_dns_name
      target_zone_id  = module.alb.alb_zone_id
    }
    www = {
      name            = "www"
      target_dns_name = module.alb.alb_dns_name
      target_zone_id  = module.alb.alb_zone_id
    }
  }
}

# ===========================================================================
# Data
# ===========================================================================
module "rds" {
  source = "../../modules/rds"

  project                    = var.project
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.eks.cluster_security_group_id]

  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  db_name        = var.db_name

  multi_az            = var.db_multi_az
  deletion_protection = var.db_deletion_protection
  skip_final_snapshot = var.db_skip_final_snapshot
}

module "elasticache" {
  source = "../../modules/elasticache"

  project                    = var.project
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.eks.cluster_security_group_id]

  node_type          = var.cache_node_type
  num_cache_clusters = var.cache_num_nodes
}

# ===========================================================================
# Security + Observability
# ===========================================================================
module "waf" {
  source = "../../modules/waf"

  project                 = var.project
  environment             = var.environment
  scope                   = "REGIONAL"
  associate_resource_arns = [module.alb.alb_arn]
}

module "secrets" {
  source = "../../modules/secrets-manager"

  project     = var.project
  environment = var.environment

  secrets = {
    app = { description = "Application runtime config (populated out-of-band)" }
  }
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project               = var.project
  environment           = var.environment
  alarm_email_endpoints = var.alarm_email_endpoints

  log_groups = {
    app = { name = "/${var.project}/${var.environment}/app", retention_in_days = 30 }
  }

  metric_alarms = {
    rds_cpu = {
      namespace           = "AWS/RDS"
      metric_name         = "CPUUtilization"
      comparison_operator = "GreaterThanThreshold"
      threshold           = 80
      evaluation_periods  = 2
      description         = "RDS CPU above 80% for 10 minutes"
      dimensions          = { DBInstanceIdentifier = module.rds.db_instance_id }
    }
  }
}
