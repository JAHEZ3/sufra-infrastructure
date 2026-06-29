# ALB module: an Application Load Balancer with its security group and
# HTTP/HTTPS listeners. Target groups/rules are expected to be attached
# by the application layer (e.g. AWS Load Balancer Controller on EKS).

locals {
  name         = "${var.project}-${var.environment}"
  enable_https = var.certificate_arn != null
}

# ---------------------------------------------------------------------------
# Security group
# ---------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "Security group for the ${local.name} ALB"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${local.name}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.ingress_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTP"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = local.enable_https ? toset(var.ingress_cidrs) : toset([])

  security_group_id = aws_security_group.alb.id
  description       = "HTTPS"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Load balancer
# ---------------------------------------------------------------------------
resource "aws_lb" "this" {
  name               = "${local.name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = "${local.name}-alb"
  })
}

# ---------------------------------------------------------------------------
# HTTP listener (port 80)
# Redirects to HTTPS when a certificate is configured, otherwise returns 404.
# ---------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = local.enable_https && var.redirect_http_to_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = local.enable_https && var.redirect_http_to_https ? [] : [1]
    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }
}

# ---------------------------------------------------------------------------
# HTTPS listener (port 443) - only when a certificate is provided
# ---------------------------------------------------------------------------
resource "aws_lb_listener" "https" {
  count = local.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_certificate" "extra" {
  for_each = local.enable_https ? toset(var.additional_certificate_arns) : toset([])

  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = each.value
}
