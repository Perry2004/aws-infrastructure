variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "domain_name" {
  description = "The domain name for the Route53 hosted zone"
  type        = string
}
