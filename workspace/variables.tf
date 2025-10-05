variable "github_oauth_token" {
  type        = string
  sensitive   = true
  description = "GitHub OAuth token ID for Terraform Cloud VCS connection"
}

variable "tfe_token" {
  type        = string
  sensitive   = true
  description = "Terraform Cloud API token"
}
