# DRAFT — not deployable yet. Remaining work before first apply:
#   1. Create modules/argocd
#   2. Update modules/eks to use node_groups map (same interface as dev)
#   3. Update modules/iam to support secrets_arn_prefix and service_accounts
#   4. Create prod terraform.tfvars (never commit — use TF_VAR_ env vars or SSM)
#   5. Update backend.tf bucket to eu-central-1 state bucket once created

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name_prefix
  cluster_name         = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = false # one NAT per AZ for HA in prod
  tags                 = local.common_tags
}

# TODO: Align with dev — use node_groups map instead of system_* variables
module "eks" {
  source = "../../modules/eks"

  cluster_name           = local.name_prefix
  kubernetes_version     = var.kubernetes_version
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnet_ids
  endpoint_public_access = false
  public_access_cidrs    = []

  node_groups = {
    system = {
      instance_types = var.system_instance_types
      capacity_type  = "ON_DEMAND"
      desired        = var.system_desired
      min            = var.system_min
      max            = var.system_max
      labels         = { role = "system" }
      taints         = []
    }
  }

  tags = local.common_tags
}

module "karpenter" {
  source = "../../modules/karpenter"

  cluster_name      = local.name_prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  node_role_arn     = module.eks.node_role_arn
  node_role_name    = module.eks.node_role_name
  tags              = local.common_tags

  depends_on = [module.eks]
}

# TODO: Extend modules/iam to support secrets_arn_prefix and service_accounts
module "iam" {
  source = "../../modules/iam"

  cluster_name      = local.name_prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  data_bucket_arn   = var.data_bucket_arn
  tags              = local.common_tags
}

# TODO: Create modules/argocd
# module "argocd" {
#   source = "../../modules/argocd"
#   chart_version = var.argocd_chart_version
#   ha_enabled    = true
#   hostname      = var.argocd_hostname
#   depends_on    = [module.eks]
# }
