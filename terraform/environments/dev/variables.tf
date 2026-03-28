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
