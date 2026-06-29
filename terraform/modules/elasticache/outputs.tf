output "replication_group_id" {
  description = "ID of the ElastiCache replication group."
  value       = aws_elasticache_replication_group.this.id
}

output "primary_endpoint_address" {
  description = "Primary endpoint for read/write operations."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Reader endpoint for load-balanced read operations."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Port the cache listens on."
  value       = var.port
}

output "security_group_id" {
  description = "ID of the cache security group."
  value       = aws_security_group.this.id
}

output "member_clusters" {
  description = "Identifiers of the individual cache nodes."
  value       = aws_elasticache_replication_group.this.member_clusters
}
