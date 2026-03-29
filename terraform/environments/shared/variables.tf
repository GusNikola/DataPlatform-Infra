variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "dataplatform"
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "domain" {
  type    = string
  default = "gusnikola.com"
}

variable "alert_email" {
  type = string
}

variable "monthly_budget_amount" {
  type    = number
  default = 250
}
