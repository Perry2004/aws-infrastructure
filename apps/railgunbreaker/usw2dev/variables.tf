variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "env_name" {
  description = "The environment name"
  type        = string
}

variable "data_retention_days" {
  description = "Number of days to retain data"
  type        = number
  default     = 90
}

variable "num_versions_to_keep" {
  description = "Number of versions to keep"
  type        = number
  default     = 3
}

variable "s3_website_prefix" {
  description = "The prefix (folder) in the S3 bucket to serve the website from"
  type        = string
  default     = "rb-website"
}

variable "github_repo" {
  description = "The GitHub repository the source code is stored in'"
  type        = string
}

variable "subdomain" {
  description = "The subdomain to use for the website"
  type        = string
  default     = "railgunbreaker.stage"
}

variable "custom_domain_name" {
  description = "The Cloudflare-managed apex domain to prepare for the RailGunBreaker website"
  type        = string
}

variable "custom_www_domain_name" {
  description = "The Cloudflare-managed www domain to prepare for the RailGunBreaker website"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "rb"
}

variable "pexels_url" {
  type = string
}
