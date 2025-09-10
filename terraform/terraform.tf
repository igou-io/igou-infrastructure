terraform {
  required_version = "~> 1.2"
  backend "s3" {
    key = "terraform.tfstate"
    bucket = "igou-tfstate"
    region = "us-east-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
     region = var.aws_region
}
