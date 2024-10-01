terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.36"
    }
  }

  backend "s3" {
    bucket = "tastefood-3soat-g13-iac"
    key    = "fiap-tech-challenge-lambda-tf"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}