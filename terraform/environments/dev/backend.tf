# Apply bootstrap/ first, then copy the outputs here
terraform {
  backend "s3" {
    bucket         = "dataplatform-terraform-state-eu-west-1"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    use_lockfile   = true
    profile        = "dataplatform-aws-deployment"
  }
}
