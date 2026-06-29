output "repository_urls" {
  description = "Map of repo name => repository URL (for docker push)."
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of repo name => repository ARN."
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}

output "repository_names" {
  description = "Map of repo key => full repository name."
  value       = { for k, v in aws_ecr_repository.this : k => v.name }
}

output "registry_ids" {
  description = "Map of repo name => registry (account) ID."
  value       = { for k, v in aws_ecr_repository.this : k => v.registry_id }
}
