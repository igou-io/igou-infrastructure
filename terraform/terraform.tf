terraform {
  required_version = "~> 1.2"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
  }
}

module "vpc_main" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  name                 = "wireguard"
  cidr                 = var.vpc_cidr
  public_subnets       = var.vpc_public_subnets
  azs                  = var.vpc_azs
  enable_dns_hostnames = true
}

provider "aws" {}
