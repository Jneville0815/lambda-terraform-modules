data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "us-east-1"
}
