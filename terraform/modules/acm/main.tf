# ACM module: requests a TLS certificate and (optionally) performs DNS
# validation by writing the validation records into a Route53 hosted zone.

locals {
  name = "${var.project}-${var.environment}"

  do_dns_validation = var.validation_method == "DNS" && var.create_validation_records
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  tags = merge(var.tags, {
    Name = "${local.name}-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# DNS validation records (one per distinct domain/SAN)
# ---------------------------------------------------------------------------
resource "aws_route53_record" "validation" {
  for_each = local.do_dns_validation ? {
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id         = var.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

# Blocks until ACM reports the certificate as issued.
resource "aws_acm_certificate_validation" "this" {
  count = local.do_dns_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
}
