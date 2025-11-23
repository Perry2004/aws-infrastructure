output "domain_name" {
  description = "The registered domain name"
  value       = aws_route53domains_registered_domain.perryz_net.domain_name
}

output "domain_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID"
  value       = aws_route53_zone.perryz_net_zone.zone_id
}

output "wildcard_certificate_arn" {
  description = "ARN of the wildcard ACM certificate"
  value       = aws_acm_certificate_validation.wildcard_cert.certificate_arn
}

output "wildcard_certificate_domain" {
  description = "Domain name of the wildcard certificate"
  value       = aws_acm_certificate.wildcard_cert.domain_name
}
