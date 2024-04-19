terraform {
  required_version = "~> 1.2"
  backend "s3" {}
  required_providers {
    "hashicorp/aws" = {
      version = "4.48.0"
    }
  }
}

provider "aws" {}
