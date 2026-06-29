output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB (use as a Route53 alias target)."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB (for Route53 alias records)."
  value       = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "http_listener_arn" {
  description = "ARN of the HTTP (port 80) listener."
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS (port 443) listener, if created."
  value       = try(aws_lb_listener.https[0].arn, null)
}
