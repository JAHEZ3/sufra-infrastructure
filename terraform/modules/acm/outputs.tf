output "certificate_arn" {
  description = "ARN of the certificate. When DNS validation runs, this is the validated ARN."
  value       = local.do_dns_validation ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "Primary domain name of the certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "Status of the certificate (e.g. ISSUED, PENDING_VALIDATION)."
  value       = aws_acm_certificate.this.status
}

output "domain_validation_options" {
  description = "Validation records, useful when records are created outside this module."
  value       = aws_acm_certificate.this.domain_validation_options
}
