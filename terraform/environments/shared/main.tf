# Shared infrastructure: AWS budget, Cloudflare DNS zone for gusnikola.com,
# wildcard ACM certificate with DNS validation via Cloudflare CNAME records.

module "billing" {
  source = "../../modules/billing"

  project_name          = var.project_name
  alert_email           = var.alert_email
  monthly_budget_amount = var.monthly_budget_amount
}

resource "cloudflare_zone" "main" {
  account = {
    id = var.cloudflare_account_id
  }
  name = var.domain
  type = "full"
}

resource "aws_acm_certificate" "wildcard" {
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  acm_validation_records = {
    for dvo in aws_acm_certificate.wildcard.domain_validation_options : dvo.resource_record_name => dvo...
  }
}

resource "cloudflare_dns_record" "acm_validation" {
  for_each = local.acm_validation_records

  zone_id = cloudflare_zone.main.id
  name    = each.key
  type    = each.value[0].resource_record_type
  content = each.value[0].resource_record_value
  ttl     = 60
  proxied = false
}

resource "aws_acm_certificate_validation" "wildcard" {
  certificate_arn         = aws_acm_certificate.wildcard.arn
  validation_record_fqdns = [for r in cloudflare_dns_record.acm_validation : r.name]
}
