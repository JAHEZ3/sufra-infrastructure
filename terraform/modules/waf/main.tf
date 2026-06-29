# WAF module: a WAFv2 Web ACL combining IP allow/block sets, AWS-managed
# rule groups, and an optional rate limit, with optional logging and
# association to regional resources (e.g. an ALB).

locals {
  name = "${var.project}-${var.environment}"

  enable_allow_list = length(var.ip_allow_list) > 0
  enable_block_list = length(var.ip_block_list) > 0
}

# ---------------------------------------------------------------------------
# IP sets
# ---------------------------------------------------------------------------
resource "aws_wafv2_ip_set" "allow" {
  count = local.enable_allow_list ? 1 : 0

  name               = "${local.name}-allow"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.ip_allow_list

  tags = merge(var.tags, { Name = "${local.name}-allow" })
}

resource "aws_wafv2_ip_set" "block" {
  count = local.enable_block_list ? 1 : 0

  name               = "${local.name}-block"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.ip_block_list

  tags = merge(var.tags, { Name = "${local.name}-block" })
}

# ---------------------------------------------------------------------------
# Web ACL
# ---------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "this" {
  name  = "${local.name}-web-acl"
  scope = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  # --- IP allow list (highest precedence) ---
  dynamic "rule" {
    for_each = local.enable_allow_list ? [1] : []
    content {
      name     = "ip-allow-list"
      priority = 0

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allow[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name}-ip-allow"
        sampled_requests_enabled   = true
      }
    }
  }

  # --- IP block list ---
  dynamic "rule" {
    for_each = local.enable_block_list ? [1] : []
    content {
      name     = "ip-block-list"
      priority = 1

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.block[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name}-ip-block"
        sampled_requests_enabled   = true
      }
    }
  }

  # --- Rate limiting ---
  dynamic "rule" {
    for_each = var.enable_rate_limiting ? [1] : []
    content {
      name     = "rate-limit"
      priority = var.rate_limit_priority

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name}-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  }

  # --- AWS-managed rule groups ---
  dynamic "rule" {
    for_each = { for g in var.managed_rule_groups : g.name => g }
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor_name
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = merge(var.tags, { Name = "${local.name}-web-acl" })
}

# ---------------------------------------------------------------------------
# Resource associations (REGIONAL only, e.g. ALB)
# ---------------------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "this" {
  # Keyed by index so the keys are known at plan time even when the resource
  # ARNs (e.g. the ALB) are created in the same apply.
  for_each = var.scope == "REGIONAL" ? { for idx, arn in var.associate_resource_arns : tostring(idx) => arn } : {}

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_logging ? 1 : 0

  # WAF log group names must start with "aws-waf-logs-".
  name              = "aws-waf-logs-${local.name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, { Name = "aws-waf-logs-${local.name}" })
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.enable_logging ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
}
