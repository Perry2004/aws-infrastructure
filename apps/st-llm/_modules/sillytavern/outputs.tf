output "static_ipv4_address" {
  description = "Static public IPv4 address attached to the Lightsail instance"
  value       = aws_lightsail_static_ip.sillytavern.ip_address
}

output "ipv6_address" {
  description = "Public IPv6 address assigned to the Lightsail instance"
  value       = aws_lightsail_instance.sillytavern.ipv6_addresses[0]
}

output "instance_username" {
  description = "Default SSH username from the selected Lightsail blueprint"
  value       = aws_lightsail_instance.sillytavern.username
}
