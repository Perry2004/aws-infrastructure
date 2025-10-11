output "domain_name" {
  description = "The registered domain name"
  value       = aws_route53domains_registered_domain.perryz_net.domain_name
}

output "domain_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID"
  value       = aws_route53_zone.perryz_net_zone.zone_id
}
