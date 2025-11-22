terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "secure-minimal"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a"]
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "logging" {
  source = "../../modules/logging"

  log_bucket_name  = "secure-logs-${var.aws_region}-${terraform.workspace}"
  enable_guardduty = true
  enable_config    = true
}

module "iam" {
  source = "../../modules/iam"

  log_bucket_arn = module.logging.log_bucket_arn
}
