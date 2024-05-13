locals {
  default_tags = {
    # Source    = "https://github.com/vtatarin/lgtm/terraform/services/eks"
    Environment = var.environment
    Service     = var.service
    Product     = "core"
    Owner       = "SRE"
  }
}
