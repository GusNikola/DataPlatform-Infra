terraform {
  backend "s3" {
    bucket       = "dataplatform-terraform-state-eu-central-1"
    key          = "shared/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
    profile      = "dataplatform-aws-deployment"
  }
}
