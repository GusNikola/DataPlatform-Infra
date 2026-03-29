output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider (used by Karpenter and IRSA)"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider (without https://)"
  value       = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}

output "node_role_arn" {
  description = "ARN of the node group IAM role (used by Karpenter)"
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "Name of the node group IAM role (used by Karpenter)"
  value       = aws_iam_role.node.name
}
