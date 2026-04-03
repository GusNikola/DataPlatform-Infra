variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https://)"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the EKS node IAM role (Karpenter-launched nodes assume this role)"
  type        = string
}

variable "node_role_name" {
  description = "Name of the EKS node IAM role"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
