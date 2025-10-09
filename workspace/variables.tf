variable "tfe_token" {
  type        = string
  sensitive   = true
  description = "Terraform Cloud API token"
}

variable "organization_name" {
  type        = string
  description = "Terraform Cloud organization name"
}
