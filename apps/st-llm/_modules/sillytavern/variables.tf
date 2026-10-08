variable "instance_name" {
  description = "Name assigned to the Lightsail instance and static IP"
  type        = string
}

variable "availability_zone" {
  description = "Lightsail availability zone"
  type        = string
}

variable "lightsail_blueprint" {
  description = "Lightsail Ubuntu operating-system blueprint ID"
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

variable "sillytavern_version" {
  description = "Pinned SillyTavern release tag without a leading v"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.sillytavern_version))
    error_message = "sillytavern_version must be a semantic version without a leading v."
  }
}

variable "hostname" {
  description = "Public hostname served by Caddy"
  type        = string

  validation {
    condition     = length(var.hostname) <= 253 && can(regex("^([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.hostname))
    error_message = "hostname must be a lowercase DNS hostname."
  }
}

variable "route53_hosted_zone" {
  description = "Route 53 hosted zone ID in which to create the hostname"
  type        = string
}
