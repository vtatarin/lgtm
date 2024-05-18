locals {
  components = [
    "tempo",
    "loki",
  ]
  mimir_components = [
    "mimir-blocks",
    "mimir-alertmanager",
    "mimir-ruler",
  ]
}

resource "aws_s3_bucket" "eks_infra" {
  for_each = toset(concat(local.components, local.mimir_components))
  bucket   = format("${module.eks.cluster_name}-%s", each.key)
}
