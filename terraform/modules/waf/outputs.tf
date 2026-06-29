output "web_acl_arn" {
  description = "ARN of the Web ACL (associate with an ALB or CloudFront)."
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_id" {
  description = "ID of the Web ACL."
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_name" {
  description = "Name of the Web ACL."
  value       = aws_wafv2_web_acl.this.name
}

output "log_group_arn" {
  description = "ARN of the WAF log group, if logging is enabled."
  value       = try(aws_cloudwatch_log_group.waf[0].arn, null)
}
