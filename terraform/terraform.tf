terraform {
  required_version = "~> 1.2"
  backend "local" {}
  required_providers {
    aws = {
      version = "~> 4.0"
    }
  }
}

provider "aws" {}
