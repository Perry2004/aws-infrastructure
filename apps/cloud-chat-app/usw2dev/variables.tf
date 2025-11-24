variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "env_name" {
  description = "The environment name"
  type        = string
}

variable "subdomain_name" {
  description = "The subdomain name for the cloud-chat-app"
  type        = string
  default     = "chat"
}

variable "app_full_name" {
  description = "The full application name"
  type        = string
  default     = "cloud-chat-app"
}

variable "app_short_name" {
  description = "The short application name"
  type        = string
  default     = "cca"
}

variable "app_repositories" {
  description = "List of ECR repositories for the app"
  type        = list(string)
  default     = []
}

variable "app_github_repo" {
  description = "The GitHub repository name for the application"
  type        = string
  default     = "Perry2004/cloud-chat-app"
}

variable "services" {
  description = "List of ECS services to deploy"
  type = list(object({
    service_name       = string
    ecr_repository_key = string
    container_port     = number
    cpu                = string
    memory             = string
    desired_count      = number
    use_load_balancer  = optional(bool, false)
  }))
  default = []
}

variable "ui_service_port" {
  description = "The port number for the UI service"
  type        = number
  default     = 1688
}
