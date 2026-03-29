output "cloudflare_zone_id" {
  value = cloudflare_zone.main.id
}

output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.wildcard.certificate_arn
}

output "nameservers" {
  description = "Point your domain registrar to these nameservers"
  value       = cloudflare_zone.main.name_servers
}
