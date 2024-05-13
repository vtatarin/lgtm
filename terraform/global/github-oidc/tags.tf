locals {
  default_tags = {
    # Source    = "https://github.com/vtatarin/lgtm/terraform/services/eks"
    Environment = "global"
    Service     = "github-oidc"
    Product     = "core"
    Owner       = "SRE"
  }
}
