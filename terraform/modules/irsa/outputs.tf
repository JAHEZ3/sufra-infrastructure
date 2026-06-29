output "role_arn" {
  description = "ARN of the IRSA role. Annotate the service account with this (eks.amazonaws.com/role-arn)."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IRSA role."
  value       = aws_iam_role.this.name
}

output "policy_arn" {
  description = "ARN of the customer-managed policy, if one was created."
  value       = try(aws_iam_policy.this[0].arn, null)
}

output "service_account_annotation" {
  description = "Annotation to put on the Kubernetes service account."
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
  }
}
