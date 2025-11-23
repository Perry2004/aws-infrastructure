variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "app_short_name" {
  description = "Short name of the application"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "capacity_provider_name" {
  description = "ECS capacity provider name"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the service"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
}

variable "cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory (in MiB) for the task"
  type        = string
  default     = "512"
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}
