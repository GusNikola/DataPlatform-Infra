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

# EKS
kubernetes_version = "1.32"

node_groups = {
  system = {
    instance_types = ["m5.large"]
    capacity_type  = "ON_DEMAND"
    desired        = 1
    min            = 1
    max            = 3
    labels         = { role = "system" }
    taints         = []
  }
  spark-executor = {
    instance_types = ["m5.4xlarge", "r5.4xlarge"]
    capacity_type  = "SPOT"
    desired        = 0
    min            = 0
    max            = 5
    labels         = { role = "spark-executor" }
    taints         = [{ key = "role", value = "spark-executor", effect = "NO_SCHEDULE" }]
  }
}
