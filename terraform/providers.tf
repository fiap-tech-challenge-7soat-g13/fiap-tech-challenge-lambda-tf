terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.36"
    }
  }
  backend "s3" {
    bucket = "terraform-state-829dbe75"
    key    = "fiap-tech-challenge-database-tf"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}