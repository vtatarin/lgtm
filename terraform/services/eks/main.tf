data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "eks" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "terraform_remote_state" "github_oidc" {
  backend = "s3"
  config = {
    bucket = "lgtm-pg"
    key    = "global/github-oidc"
    region = "us-east-1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.10"

  cluster_name    = "${var.service}-${var.environment}"
  cluster_version = var.eks_version

  cluster_endpoint_public_access = var.eks_public_access

  cluster_addons = {
    coredns = {
      addon_version = "v1.11.1-eksbuild.8"
    }
    kube-proxy = {
      addon_version = "v1.29.1-eksbuild.2"
    }
    vpc-cni = {
      addon_version = "v1.18.1-eksbuild.1"
    }
  }

  vpc_id                    = var.vpc_id
  subnet_ids                = data.aws_subnets.eks.ids
  cluster_service_ipv4_cidr = "10.100.0.0/16"

  # Init node group for basic workloads to run (e.g. Karpenter, etc.)
  eks_managed_node_groups = {
    init = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["m7i.xlarge"]
      iam_role_additional_policies = {
        SSM = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    # Tag node group resources for Karpenter auto-discovery
    "karpenter.sh/discovery" = "${var.service}-${var.environment}"
  }

  access_entries = {
    "cicd" = {
      principal_arn = data.terraform_remote_state.github_oidc.outputs.cicd_iam_role_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    "AdministratorAccess" = {
      principal_arn = "arn:aws:iam::245582572290:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_20232cf5120c756c"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
