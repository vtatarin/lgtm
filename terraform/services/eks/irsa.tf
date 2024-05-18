module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "${module.eks.cluster_name}-${each.key}"

  attach_load_balancer_controller_policy = lookup(each.value, "attach_load_balancer_controller_policy", false)
  attach_external_dns_policy             = lookup(each.value, "attach_external_dns_policy", false)
  attach_ebs_csi_policy                  = lookup(each.value, "attach_ebs_csi_policy", false)
  attach_karpenter_controller_policy     = lookup(each.value, "attach_karpenter_controller_policy", false)

  enable_karpenter_instance_profile_creation = lookup(each.value, "enable_karpenter_instance_profile_creation", false)
  karpenter_controller_cluster_name          = module.eks.cluster_name
  karpenter_controller_node_iam_role_arns    = [module.eks.eks_managed_node_groups["init"].iam_role_arn]

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "${format("%s:%s",
          lookup(each.value, "namespace", each.key),
          lookup(each.value, "sa_name", each.key)
        )}"
      ]
    }
  }

  role_policy_arns = lookup(each.value, "role_policy_arn", false) != false ? {
    policy = lookup(each.value, "role_policy_arn", null)
  } : {}

  for_each = {
    aws-lb-controller = {
      attach_load_balancer_controller_policy = true
    }
    external-dns = {
      attach_external_dns_policy = true
    }
    ebs-csi = {
      attach_ebs_csi_policy = true
    }
    karpenter = {
      attach_karpenter_controller_policy         = true
      enable_karpenter_instance_profile_creation = true
      role_policy_arn                            = aws_iam_policy.karpenter.arn
    }
    tempo = {
      role_policy_arn = aws_iam_policy.eks_infra_s3["tempo"].arn
    }
    mimir = {
      role_policy_arn = aws_iam_policy.eks_infra_s3["mimir"].arn
    }
    loki = {
      role_policy_arn = aws_iam_policy.eks_infra_s3["loki"].arn
    }
  }
}

resource "aws_iam_policy" "eks_infra_s3" {
  for_each    = toset(concat(local.components, ["mimir"]))
  name        = "${each.key}-access-policy"
  path        = "/"
  description = "Access policy for ${module.eks.cluster_name} S3 bucket ${each.key}"

  policy = data.aws_iam_policy_document.eks_infra_s3[each.key].json
}

data "aws_iam_policy_document" "eks_infra_s3" {
  for_each = toset(concat(local.components, ["mimir"]))

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]

    resources = each.key != "mimir" ? [
      aws_s3_bucket.eks_infra[each.key].arn,
      "${aws_s3_bucket.eks_infra[each.key].arn}/*",
    ] : flatten([for c in local.mimir_components : [aws_s3_bucket.eks_infra[c].arn, "${aws_s3_bucket.eks_infra[c].arn}/*"]])
  }
}

# Hotfix
# LaunchTemplates are not receiving required tags (?)
resource "aws_iam_policy" "karpenter" {
  name = "karpenter-hotfix"
  path = "/"

  policy = data.aws_iam_policy_document.karpenter.json
}

data "aws_iam_policy_document" "karpenter" {

  statement {
    actions = [
      "ec2:RunInstances",
      "ec2:DeleteLaunchTemplate",
    ]

    resources = ["*"]
  }
}
