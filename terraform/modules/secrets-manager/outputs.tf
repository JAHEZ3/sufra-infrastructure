output "secret_arns" {
  description = "Map of secret key => ARN (grant IRSA roles read access to these)."
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "secret_names" {
  description = "Map of secret key => full secret name."
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.name }
}

output "secret_ids" {
  description = "Map of secret key => secret ID."
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.id }
}
