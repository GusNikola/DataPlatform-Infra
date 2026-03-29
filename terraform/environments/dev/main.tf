locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  name         = local.name_prefix
  repositories = var.ecr_repositories
  tags         = local.common_tags
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name_prefix
  cluster_name         = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = true
  tags                 = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name           = local.name_prefix
  kubernetes_version     = var.kubernetes_version
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnet_ids
  endpoint_public_access = true
  node_groups            = var.node_groups
  tags                   = local.common_tags
}
