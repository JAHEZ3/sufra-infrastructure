# ElastiCache module: a Redis (or Valkey) replication group in private
# subnets with a dedicated security group, encryption, and automatic failover.

locals {
  name = "${var.project}-${var.environment}"
}

# ---------------------------------------------------------------------------
# Subnet group
# ---------------------------------------------------------------------------
resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.name}-cache-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name}-cache-subnet-group"
  })
}

# ---------------------------------------------------------------------------
# Security group
# ---------------------------------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${local.name}-cache-sg"
  description = "Security group for the ${local.name} cache"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${local.name}-cache-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "from_sg" {
  # Keyed by index so the set keys are known at plan time even when the SG IDs
  # come from resources created in the same apply (e.g. the EKS cluster SG).
  for_each = { for idx, sg_id in var.allowed_security_group_ids : tostring(idx) => sg_id }

  security_group_id            = aws_security_group.this.id
  description                  = "Cache access from security group"
  referenced_security_group_id = each.value
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.this.id
  description       = "Cache access from CIDR"
  cidr_ipv4         = each.value
  from_port         = var.port
  to_port           = var.port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Replication group
# ---------------------------------------------------------------------------
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${local.name}-cache"
  description          = "${local.name} ${var.engine} replication group"

  engine         = var.engine
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled && var.num_cache_clusters > 1
  multi_az_enabled           = var.multi_az_enabled && var.num_cache_clusters > 1

  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.this.id]
  parameter_group_name = var.parameter_group_name

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.transit_encryption_enabled ? var.auth_token : null
  kms_key_id                 = var.at_rest_encryption_enabled ? var.kms_key_id : null

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window
  apply_immediately        = var.apply_immediately

  tags = merge(var.tags, {
    Name = "${local.name}-cache"
  })

  lifecycle {
    ignore_changes = [auth_token]
  }
}
