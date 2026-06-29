output "log_group_names" {
  description = "Map of log group key => name."
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "log_group_arns" {
  description = "Map of log group key => ARN."
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

output "sns_topic_arn" {
  description = "ARN of the alarm SNS topic (created or existing)."
  value       = var.existing_sns_topic_arn != null ? var.existing_sns_topic_arn : try(aws_sns_topic.alarms[0].arn, null)
}

output "alarm_names" {
  description = "Map of alarm key => alarm name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.alarm_name }
}
