# variable "aws_region" {
#   description = "The AWS region to deploy resources in"
#   type        = string
#   default     = "us-west-2"
# }

# variable "iam_admin_users" {
#   description = "List of IAM Identity Center admin users to create"
#   type = list(object({
#     username     = string
#     email        = string
#     first_name   = string
#     last_name    = string
#     display_name = string
#   }))
#   default   = []
#   sensitive = true
# }
