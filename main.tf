terraform {
  required_version = "1.10.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
  backend "s3" {
    bucket = "always-upgrade-terraform-state"
    key    = "clearskies.info.json"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region
}
