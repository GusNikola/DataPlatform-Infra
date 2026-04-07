aws_region   = "eu-central-1"
project_name = "dataplatform"
environment  = "dev"

# ECR
ecr_repositories = ["spark"]

# VPC
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["eu-central-1a", "eu-central-1b"]
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.16.0/21", "10.0.24.0/21"]

# Cloudflare
cloudflare_api_token = "cfut_SjAIL838WjB0njW9rQbi89FMIHIB396UMJb7tVjY71f6f462"
cloudflare_zone_id   = "0e75705411b03407fccf07286d74acfe"
nlb_hostname         = "a8633a64340c3455e9b1c43df19fd6b0-d0a9831f6c50e62e.elb.eu-central-1.amazonaws.com"
dns_records          = ["argocd", "grafana", "kibana", "airflow", "spark-history"]
lets_encrypt_email   = "ngusic@europecloudatlas.com"
grafana_admin_password = "0e75705411"

# EKS
eks_public_access_cidrs = ["24.135.66.25/32"]
kubernetes_version = "1.32"

node_groups = {
  core = {
    instance_types = ["m5.large"]
    capacity_type  = "ON_DEMAND"
    desired        = 1
    min            = 1
    max            = 1
    labels         = { role = "core" }
    taints = [
      {
        key    = "role"
        value  = "core"
        effect = "NO_SCHEDULE"
      }
    ]
  }
}
