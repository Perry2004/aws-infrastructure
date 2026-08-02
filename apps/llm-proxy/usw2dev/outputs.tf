output "api_base_url" {
  description = "OpenAI-compatible API base URL"
  value       = "https://${local.fqdn}/v1"
}

output "hostname" {
  description = "Public proxy hostname"
  value       = local.fqdn
}

output "static_ipv4_address" {
  description = "Static public IPv4 address attached to the Lightsail instance"
  value       = module.cli_proxy_api.static_ipv4_address
}

output "ipv6_address" {
  description = "Stable public IPv6 address assigned to the Lightsail instance"
  value       = module.cli_proxy_api.ipv6_address
}

output "ssh_command" {
  description = "SSH command using the Lightsail default regional private key"
  value       = "ssh -i ~/.ssh/LightsailDefaultKey-${var.aws_region}.pem ${module.cli_proxy_api.instance_username}@${module.cli_proxy_api.static_ipv4_address}"
}
