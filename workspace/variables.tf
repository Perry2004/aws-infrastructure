variable "github_oauth_token" {
  type        = string
  sensitive   = true
  description = "GitHub OAuth token ID for Terraform Cloud VCS connection"
}
