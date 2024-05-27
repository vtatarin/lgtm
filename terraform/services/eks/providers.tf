provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  backend "s3" {
    bucket = "lgtm-pg"
    key    = "services/eks"
    region = "us-east-1"
  }
  required_version = "~> 1.8"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
