output "db_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS instance ARN."
  value       = aws_db_instance.this.arn
}

output "endpoint" {
  description = "Connection endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "DNS hostname of the database."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Database port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the initial database."
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Master username."
  value       = aws_db_instance.this.username
}

output "security_group_id" {
  description = "ID of the database security group."
  value       = aws_security_group.this.id
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the master password (when RDS-managed)."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}
