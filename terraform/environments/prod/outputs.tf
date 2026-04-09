# DRAFT — prod environment is not yet deployable.
# modules/argocd does not exist yet.
# IAM module interface does not yet support secrets_arn_prefix / service_accounts.
# EKS module interface does not use system_instance_types — use node_groups map instead.

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
