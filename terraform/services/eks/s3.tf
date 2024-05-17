locals {
  s3_buckets = toset([
    "tempo",
    "mimir",
    "loki",
  ])
}

resource "aws_s3_bucket" "eks_infra" {
  for_each = local.s3_buckets
  bucket   = format("${module.eks.cluster_name}-%s", each.key)
}
