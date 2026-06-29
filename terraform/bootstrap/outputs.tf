output "state_bucket_name" {
  description = "Name of the Terraform state bucket. Use this in each environment's backend.tf."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the state bucket."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB lock table. Use this in each environment's backend.tf."
  value       = aws_dynamodb_table.locks.name
}

output "region" {
  description = "Region the backend resources live in."
  value       = var.aws_region
}

output "github_ci_role_arn" {
  description = "ARN of the GitHub Actions CI role. Set this as the repo secret AWS_ROLE_ARN."
  value       = try(aws_iam_role.github_ci[0].arn, null)
}
