variable "tfe_token" {
  type        = string
  sensitive   = true
  description = "Terraform Cloud API token"
}

variable "organization_name" {
  type        = string
  description = "Terraform Cloud organization name"
}

variable "workspaces" {
  description = "List of workspaces to create in Terraform Cloud"
  type = list(object({
    name                  = string
    description           = string
    working_directory     = string
    additional_watch_dirs = optional(list(string), [])
  }))
  default = []
}
