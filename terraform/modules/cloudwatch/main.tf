# CloudWatch module: log groups, an SNS topic for notifications, and
# metric alarms that publish to that topic.

locals {
  name = "${var.project}-${var.environment}"

  create_topic   = var.existing_sns_topic_arn == null && var.create_sns_topic
  alarm_sns_arns = compact([var.existing_sns_topic_arn, try(aws_sns_topic.alarms[0].arn, null)])
}

# ---------------------------------------------------------------------------
# Log groups
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

# ---------------------------------------------------------------------------
# SNS topic for alarm notifications
# ---------------------------------------------------------------------------
resource "aws_sns_topic" "alarms" {
  count = local.create_topic ? 1 : 0

  name = "${local.name}-alarms"

  tags = merge(var.tags, {
    Name = "${local.name}-alarms"
  })
}

resource "aws_sns_topic_subscription" "email" {
  for_each = local.create_topic ? toset(var.alarm_email_endpoints) : toset([])

  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = each.value
}

# ---------------------------------------------------------------------------
# Metric alarms
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.metric_alarms

  alarm_name          = "${local.name}-${each.key}"
  alarm_description   = each.value.description
  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  statistic           = each.value.statistic
  comparison_operator = each.value.comparison_operator
  threshold           = each.value.threshold
  period              = each.value.period
  evaluation_periods  = each.value.evaluation_periods
  treat_missing_data  = each.value.treat_missing_data
  dimensions          = each.value.dimensions

  alarm_actions = local.alarm_sns_arns
  ok_actions    = local.alarm_sns_arns

  tags = merge(var.tags, {
    Name = "${local.name}-${each.key}"
  })
}
