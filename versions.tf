terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "venky-terraform-state-2026-unique"
    key          = "ecr-deployment/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}
