locals {
  s3_buckets = toset(formatlist("${module.eks.cluster_name}-%s", [
    "tempo",
    "mimir",
    "loki",
  ]))
}

resource "aws_s3_bucket" "eks_infra" {
  for_each = local.s3_buckets
  bucket   = each.key
}

# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "TempoPermissions",
#             "Effect": "Allow",
#             "Action": [
#                 "s3:PutObject",
#                 "s3:GetObject",
#                 "s3:ListBucket",
#                 "s3:DeleteObject",
#                 "s3:GetObjectTagging",
#                 "s3:PutObjectTagging"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::<bucketname>/*",
#                 "arn:aws:s3:::<bucketname>"
#             ]
#         }
#     ]
# }
