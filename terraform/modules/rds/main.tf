# RDS module: a managed relational database with a private subnet group,
# a dedicated security group, optional custom parameter group, and either
# RDS-managed master credentials (Secrets Manager) or a supplied password.

locals {
  name = "${var.project}-${var.environment}"

  default_ports = {
    postgres = 5432
    mysql    = 3306
    mariadb  = 3306
  }
  port = coalesce(var.port, lookup(local.default_ports, var.engine, 5432))

  create_parameter_group = var.parameter_group_family != null
}

# ---------------------------------------------------------------------------
# Subnet group
# ---------------------------------------------------------------------------
resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name}-db-subnet-group"
  })
}

# ---------------------------------------------------------------------------
# Security group
# ---------------------------------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${local.name}-db-sg"
  description = "Security group for the ${local.name} database"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${local.name}-db-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "from_sg" {
  # Keyed by index so the set keys are known at plan time even when the SG IDs
  # come from resources created in the same apply (e.g. the EKS cluster SG).
  for_each = { for idx, sg_id in var.allowed_security_group_ids : tostring(idx) => sg_id }

  security_group_id            = aws_security_group.this.id
  description                  = "DB access from security group"
  referenced_security_group_id = each.value
  from_port                    = local.port
  to_port                      = local.port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.this.id
  description       = "DB access from CIDR"
  cidr_ipv4         = each.value
  from_port         = local.port
  to_port           = local.port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Parameter group (optional)
# ---------------------------------------------------------------------------
resource "aws_db_parameter_group" "this" {
  count = local.create_parameter_group ? 1 : 0

  name   = "${local.name}-db-params"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name}-db-params"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Database instance
# ---------------------------------------------------------------------------
resource "aws_db_instance" "this" {
  identifier = "${local.name}-db"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  port           = local.port

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name  = var.db_name
  username = var.username

  # When manage_master_password is true, RDS stores the password in Secrets
  # Manager and `password` must be omitted.
  manage_master_user_password = var.manage_master_password ? true : null
  password                    = var.manage_master_password ? null : var.password

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = local.create_parameter_group ? aws_db_parameter_group.this[0].name : null

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  performance_insights_enabled = var.performance_insights_enabled

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name}-db-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  apply_immediately         = false

  tags = merge(var.tags, {
    Name = "${local.name}-db"
  })

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}
