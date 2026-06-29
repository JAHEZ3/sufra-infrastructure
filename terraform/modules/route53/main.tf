# Route53 module: a hosted zone (or reference to an existing one) plus
# alias records (ALB/CloudFront) and standard records (A/CNAME/TXT/MX/...).

locals {
  name = "${var.project}-${var.environment}"

  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.existing_zone_id
}

resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name    = var.domain_name
  comment = "${local.name} hosted zone"

  dynamic "vpc" {
    for_each = var.private_zone && var.vpc_id != null ? [var.vpc_id] : []
    content {
      vpc_id = vpc.value
    }
  }

  tags = merge(var.tags, {
    Name = var.domain_name
  })
}

# ---------------------------------------------------------------------------
# Alias records (e.g. apex / www -> ALB)
# ---------------------------------------------------------------------------
resource "aws_route53_record" "alias" {
  for_each = var.alias_records

  zone_id = local.zone_id
  name = (
    each.value.name == "" || each.value.name == "@"
    ? var.domain_name
    : "${each.value.name}.${var.domain_name}"
  )
  type = "A"

  alias {
    name                   = each.value.target_dns_name
    zone_id                = each.value.target_zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}

# ---------------------------------------------------------------------------
# Standard records (A/CNAME/TXT/MX/...)
# ---------------------------------------------------------------------------
resource "aws_route53_record" "standard" {
  for_each = var.records

  zone_id = local.zone_id
  name = (
    each.value.name == "" || each.value.name == "@"
    ? var.domain_name
    : "${each.value.name}.${var.domain_name}"
  )
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.values
}
