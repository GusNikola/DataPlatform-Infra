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

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "spark_role_arn" {
  value = module.iam.spark_role_arn
}

output "airflow_role_arn" {
  value = module.iam.airflow_role_arn
}

output "data_bucket_name" {
  value = module.s3.bucket_name
}

output "karpenter_interruption_queue" {
  value = module.karpenter.interruption_queue_name
}
