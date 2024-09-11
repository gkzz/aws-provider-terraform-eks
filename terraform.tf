terraform {
  required_version = "= 1.1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.20.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
  backend "s3" {
    bucket  = "bucket-for-aws-provider-terraform-eks"
    region  = "ap-northeast-1"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}
