module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "${module.eks.cluster_name}-${each.key}"

  attach_load_balancer_controller_policy     = lookup(each.value, "attach_load_balancer_controller_policy", false)
  attach_external_dns_policy                 = lookup(each.value, "attach_external_dns_policy", false)
  attach_ebs_csi_policy                      = lookup(each.value, "attach_ebs_csi_policy", false)
  attach_karpenter_controller_policy         = lookup(each.value, "attach_karpenter_controller_policy", false)
  enable_karpenter_instance_profile_creation = lookup(each.value, "enable_karpenter_instance_profile_creation", false)

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
  for_each    = local.s3_buckets
  name        = "${each.key}-access-policy"
  path        = "/"
  description = "Access policy for ${module.eks.cluster_name} S3 bucket ${each.key}"

  policy = data.aws_iam_policy_document.eks_infra_s3[each.key].json
}

data "aws_iam_policy_document" "eks_infra_s3" {
  for_each = local.s3_buckets

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]

    resources = [
      aws_s3_bucket.eks_infra[each.key].arn,
      "${aws_s3_bucket.eks_infra[each.key].arn}/*",
    ]
  }
}
