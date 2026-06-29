output "zone_id" {
  description = "Hosted zone ID (created or existing). Feed into the acm module."
  value       = local.zone_id
}

output "zone_name" {
  description = "Hosted zone domain name."
  value       = var.domain_name
}

output "name_servers" {
  description = "Authoritative name servers for the created public zone (set these at your registrar)."
  value       = try(aws_route53_zone.this[0].name_servers, null)
}

output "alias_record_fqdns" {
  description = "Map of alias record key => FQDN."
  value       = { for k, v in aws_route53_record.alias : k => v.fqdn }
}
