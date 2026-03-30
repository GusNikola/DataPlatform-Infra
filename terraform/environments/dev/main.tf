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

  cluster_name            = local.name_prefix
  kubernetes_version      = var.kubernetes_version
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  endpoint_public_access  = true
  public_access_cidrs     = var.eks_public_access_cidrs
  node_groups             = var.node_groups
  tags                    = local.common_tags
}

module "ingress" {
  source = "../../modules/ingress"

  tags = local.common_tags

  depends_on = [module.eks]
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }
  data = {
    api-token = var.cloudflare_api_token
  }
  depends_on = [module.ingress]
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = { name = "letsencrypt-prod" }
    spec = {
      acme = {
        server              = "https://acme-v02.api.letsencrypt.org/directory"
        email               = var.lets_encrypt_email
        privateKeySecretRef = { name = "letsencrypt-prod" }
        solvers = [{
          dns01 = {
            cloudflare = {
              apiTokenSecretRef = {
                name = "cloudflare-api-token"
                key  = "api-token"
              }
            }
          }
        }]
      }
    }
  }
  depends_on = [kubernetes_secret.cloudflare_api_token]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "tracing" {
  metadata {
    name = "tracing"
  }
  depends_on = [module.eks]
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    admin-user     = "admin"
    admin-password = var.grafana_admin_password
  }
}

resource "cloudflare_dns_record" "services" {
  for_each = toset(var.dns_records)

  zone_id = var.cloudflare_zone_id
  name    = "${each.value}.gusnikola.com"
  type    = "CNAME"
  content = var.nlb_hostname
  ttl     = 60
  proxied = false
}
