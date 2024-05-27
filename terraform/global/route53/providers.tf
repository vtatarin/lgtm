provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  backend "s3" {
    bucket = "lgtm-pg"
    region = "us-east-1"
    key    = "global/route53"
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
