output "chat_subdomain_zone_id" {
  description = "The Route 53 Hosted Zone ID for chat.perryz.net"
  value       = aws_route53_zone.chat_subdomain_zone.zone_id
}
