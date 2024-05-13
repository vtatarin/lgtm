provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  backend "s3" {
    bucket = "lgtm-playground-tfstate-20240510003852147300000001"
    key    = "437023642520/us-east-2/sandbox/eks"
    region = "us-east-2"
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
