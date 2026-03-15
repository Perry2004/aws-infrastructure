variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "env_name" {
  description = "The environment name"
  type        = string
}

variable "app_name" {
  description = "The application name"
  type        = string
  default     = "gp-news"
}
