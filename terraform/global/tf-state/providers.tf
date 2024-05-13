provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
