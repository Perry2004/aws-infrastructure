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
    health_check_path  = optional(string, "")
  }))
  default = []
}

variable "ui_service_port" {
  description = "The port number for the UI service"
  type        = number
  default     = 1688
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logs to S3"
  type        = bool
  default     = true
}

variable "alb_access_logs_bucket_name" {
  description = "Optional pre-existing S3 bucket to use for ALB access logs. If empty, a new bucket will be created."
  type        = string
  default     = ""
}

variable "alb_access_logs_bucket_prefix" {
  description = "Prefix to use for ALB logs inside the S3 bucket (do not use 'AWSLogs')."
  type        = string
  default     = "alb-logs"
}

variable "enable_apigw_access_logs" {
  description = "Enable API Gateway HTTP (apigatewayv2) access logs to CloudWatch"
  type        = bool
  default     = true
}

variable "apigw_access_log_retention_days" {
  description = "CloudWatch Log retention in days for the API Gateway access logs"
  type        = number
  default     = 30
}

variable "enable_cloudfront_access_logs" {
  description = "Enable CloudFront access logs to S3"
  type        = bool
  default     = true
}

variable "cloudfront_access_logs_bucket_name" {
  description = "Optional pre-existing S3 bucket to use for CloudFront access logs. If empty, a new bucket will be created."
  type        = string
  default     = ""
}

variable "cloudfront_access_logs_bucket_prefix" {
  description = "Prefix to use for CloudFront logs inside the S3 bucket."
  type        = string
  default     = "cloudfront-logs"
}
