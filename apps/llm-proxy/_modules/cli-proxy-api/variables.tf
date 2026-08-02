variable "instance_name" {
  description = "Name assigned to the Lightsail instance and static IP"
  type        = string
}

variable "availability_zone" {
  description = "Lightsail availability zone"
  type        = string
}

variable "lightsail_blueprint" {
  description = "Lightsail operating-system blueprint ID"
  type        = string
}

variable "lightsail_bundle" {
  description = "Lightsail compute bundle ID"
  type        = string
}

variable "admin_ipv4_cidr" {
  description = "Trusted administrator IPv4 CIDR allowed to connect over SSH"
  type        = string
}

variable "cliproxyapi_version" {
  description = "Pinned CLIProxyAPI release version without the leading v"
  type        = string
}

variable "hostname" {
  description = "Public hostname served by Caddy"
  type        = string
}

variable "route53_hosted_zone" {
  description = "Route 53 hosted zone ID in which to create the hostname"
  type        = string
}
