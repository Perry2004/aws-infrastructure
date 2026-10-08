output "web_url" {
  description = "Password-protected SillyTavern URL"
  value       = "https://${local.fqdn}"
}

output "hostname" {
  description = "Public SillyTavern hostname"
  value       = local.fqdn
}

output "static_ipv4_address" {
  description = "Static public IPv4 address attached to the Lightsail instance"
  value       = module.sillytavern.static_ipv4_address
}

output "ipv6_address" {
  description = "Public IPv6 address assigned to the Lightsail instance"
  value       = module.sillytavern.ipv6_address
}

output "ssh_command" {
  description = "SSH command using the Lightsail default regional private key"
  value       = "ssh -i ~/.ssh/LightsailDefaultKey-${var.aws_region}.pem ${module.sillytavern.instance_username}@${module.sillytavern.static_ipv4_address}"
}
