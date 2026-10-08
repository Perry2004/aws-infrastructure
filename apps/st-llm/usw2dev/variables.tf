variable "aws_region" {
  description = "AWS region in which to deploy SillyTavern"
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
  default     = "st-llm"
}

variable "subdomain_name" {
  description = "Subdomain created beneath the shared Route 53 zone"
  type        = string
  default     = "st"
}

variable "lightsail_blueprint_id" {
  description = "Ubuntu blueprint supported by the bootstrap script"
  type        = string
  default     = "ubuntu_24_04"

  validation {
    condition     = var.lightsail_blueprint_id == "ubuntu_24_04"
    error_message = "The bootstrap script requires the ubuntu_24_04 blueprint."
  }
}

variable "lightsail_bundle_id" {
  type    = string
  default = "micro_3_0" // 1 GB RAM
}

variable "admin_ipv4_cidr" {
  description = "Trusted administrator IPv4 CIDR allowed to connect over SSH"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_ipv4_cidr)) && var.admin_ipv4_cidr != "0.0.0.0/0"
    error_message = "admin_ipv4_cidr must be a restricted IPv4 CIDR, for example 203.0.113.10/32."
  }
}

variable "sillytavern_version" {
  description = "Pinned SillyTavern release tag, without a leading v; used on first boot only"
  type        = string
  default     = "1.19.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.sillytavern_version))
    error_message = "sillytavern_version must be a semantic version without a leading v."
  }
}
