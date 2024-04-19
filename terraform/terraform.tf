terraform {
  required_version = "~> 1.2"
  backend "s3" {}
  required_providers {
    aws = {
      version = "~> 4.67.0"
    }
  }
}

provider "aws" {}
