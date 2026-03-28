aws_region   = "eu-west-1"
project_name = "dataplatform"
environment  = "dev"

# ECR
ecr_repositories = ["spark"]

# VPC
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.16.0/21", "10.0.24.0/21"]
