variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

# ECR
variable "ecr_repositories" {
  description = "ECR repository names to create under the project namespace"
  type        = list(string)
  default     = ["spark"]
}

# VPC
variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

# Cloudflare
variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  type = string
}

variable "nlb_hostname" {
  description = "NLB hostname from ingress-nginx service — fill after first ingress apply"
  type        = string
  default     = ""
}

variable "dns_records" {
  description = "List of subdomains to create CNAME records for (e.g. [\"argocd\", \"airflow\"])"
  type        = list(string)
  default     = []
}

variable "lets_encrypt_email" {
  description = "Email address for Let's Encrypt certificate notifications"
  type        = string
}

# EKS
variable "eks_public_access_cidrs" {
  description = "CIDRs allowed to access the EKS public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# EKS
variable "kubernetes_version" {
  type = string
}

variable "node_groups" {
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    desired        = number
    min            = number
    max            = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
}
