variable "aws_region" {
  description = "AWS region in which to deploy the proxy"
  type        = string
  default     = "us-west-2"
}

variable "availability_zone" {
  description = "Lightsail availability zone"
  type        = string
  default     = "us-west-2a"
}

variable "env_name" {
  description = "Environment name"
  type        = string
  default     = "usw2dev"
}

variable "project_name" {
  description = "Project name used for AWS tags and resource names"
  type        = string
  default     = "llm-proxy"
}

variable "subdomain_name" {
  description = "Subdomain created beneath the shared Route 53 zone"
  type        = string
  default     = "llm"
}

variable "lightsail_blueprint_id" {
  description = "Lightsail operating-system blueprint"
  type        = string
  default     = "ubuntu_24_04"
}

variable "lightsail_bundle_id" {
  description = "Lightsail bundle; use micro_3_0 if the Nano instance is memory constrained"
  type        = string
  default     = "nano_3_0"

  validation {
    condition     = contains(["nano_3_0", "micro_3_0"], var.lightsail_bundle_id)
    error_message = "lightsail_bundle_id must be nano_3_0 or micro_3_0."
  }
}

variable "admin_ipv4_cidr" {
  description = "Trusted administrator IPv4 CIDR allowed to connect over SSH"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_ipv4_cidr))
    error_message = "admin_ipv4_cidr must be a valid IPv4 CIDR, for example 203.0.113.10/32."
  }
}

variable "cliproxyapi_version" {
  description = "Pinned CLIProxyAPI release version without the leading v"
  type        = string
  default     = "7.2.113"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.cliproxyapi_version))
    error_message = "cliproxyapi_version must be a semantic version without a leading v."
  }
}
