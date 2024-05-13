# Already exists in the AWS account
# resource "aws_iam_openid_connect_provider" "github_oidc" {
#   client_id_list = [
#     "sts.amazonaws.com",
#   ]
#   thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
#   url             = "https://token.actions.githubusercontent.com"
# }


data "aws_iam_policy_document" "github_oidc_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::437023642520:oidc-provider/token.actions.githubusercontent.com"] # mocked
      # identifiers = [aws_iam_openid_connect_provider.githubOidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:vtatarin/lgtm:*"]
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
