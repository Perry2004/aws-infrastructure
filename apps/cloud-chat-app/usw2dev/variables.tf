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
