data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
   url             = "https://token.actions.githubusercontent.com"
   client_id_list  = ["sts.amazonaws.com"]
   thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
 }


data "aws_iam_policy_document" "github_oidc_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:pbunakalia/lgtm:*"]
    }
  }
}

resource "aws_iam_role" "github_cicd" {
  name               = "GithubActionsCICD"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}
