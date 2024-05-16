data "terraform_remote_state" "route53" {
  backend = "s3"
  config = {
    bucket = "lgtm-playground-tfstate-20240510003852147300000001"
    key    = "global/route53"
    region = "us-east-2"
  }
}

resource "aws_route53_zone" "main" {
  name    = "${var.environment}.${data.terraform_remote_state.route53.outputs.zone_name}"
  comment = "Zone for ${var.environment} environment. Associate with EKS cluster: ${module.eks.cluster_name}"
}

resource "aws_route53_record" "main_ns" {
  name    = aws_route53_zone.main.name
  type    = "NS"
  zone_id = data.terraform_remote_state.route53.outputs.zone_id

  records = aws_route53_zone.main.name_servers
}

resource "aws_acm_certificate" "main" {
  domain_name       = aws_route53_zone.main.name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${aws_route53_zone.main.name}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "main_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}
