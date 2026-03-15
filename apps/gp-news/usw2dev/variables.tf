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

variable "schedule_daily_utc_time" {
  description = "The UTC time to schedule the daily scraper (in HH:MM format)"
  type        = list(string)
  default     = ["00:00"]
}

variable "lambda_environment_variables" {
  description = "A map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "ssm_parameters" {
  description = "A map of SSM parameter environment variable names to their SSM paths"
  type        = map(string)
  default     = {}
}