locals {
  default_tags = {
    Environment = var.environment
    Service     = var.service
    Product     = "core"
    Owner       = "SRE"
  }
}
