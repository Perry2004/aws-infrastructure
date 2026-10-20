variable "instance_name" {
  description = "Name assigned to the Lightsail instance and static IP"
  type        = string
}

variable "key_pair_name" {
  description = "Lightsail SSH key pair name; null uses the default regional key"
  type        = string
  default     = null
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
