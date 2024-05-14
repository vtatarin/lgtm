output "lgtm_vtatarin_xyz_ns" {
  value = aws_route53_zone.lgtm_vtatarin_xyz.name_servers
}

output "zone_name" {
  value = aws_route53_zone.lgtm_vtatarin_xyz.name
}

output "zone_id" {
  value = aws_route53_zone.lgtm_vtatarin_xyz.id
}
