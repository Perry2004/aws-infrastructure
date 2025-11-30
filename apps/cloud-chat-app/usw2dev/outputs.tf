output "ses_domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = aws_ses_domain_identity.chat_domain.arn
}

output "ses_domain_identity_verification_token" {
  description = "Verification token for the SES domain identity"
  value       = aws_ses_domain_identity.chat_domain.verification_token
}

output "ses_domain" {
  description = "The verified SES domain"
  value       = aws_ses_domain_identity.chat_domain.domain
}

output "ses_dkim_tokens" {
  description = "DKIM tokens for the SES domain"
  value       = aws_ses_domain_dkim.chat_domain.dkim_tokens
}

output "app_ecr_repositories" {
  description = "List of ECR repositories created for the app"
  value       = [for repo in aws_ecr_repository.app_repositories : repo]
}

output "gha_iam_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}

output "public_subnet_a_id" {
  description = "ID of the public subnet a"
  value       = aws_subnet.cca_public_a.id
}

output "public_subnet_b_id" {
  description = "ID of the public subnet b"
  value       = aws_subnet.cca_public_b.id
}

output "private_subnet_a_id" {
  description = "ID of the private subnet a"
  value       = aws_subnet.cca_private_a.id
}

output "private_subnet_b_id" {
  description = "ID of the private subnet b"
  value       = aws_subnet.cca_private_b.id
}

output "public_subnet_a_cidr" {
  description = "CIDR block of the public subnet a"
  value       = aws_subnet.cca_public_a.cidr_block
}

output "public_subnet_b_cidr" {
  description = "CIDR block of the public subnet b"
  value       = aws_subnet.cca_public_b.cidr_block
}

output "private_subnet_a_cidr" {
  description = "CIDR block of the private subnet a"
  value       = aws_subnet.cca_private_a.cidr_block
}

output "private_subnet_b_cidr" {
  description = "CIDR block of the private subnet b"
  value       = aws_subnet.cca_private_b.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.cca_igw.id
}

output "nat_gateway_a_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.cca_nat_a.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.cca_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.cca_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.cca_alb.zone_id
}

output "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer"
  value       = aws_security_group.cca_alb_sg.id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.cca_tg.arn
}

output "api_alb_arn" {
  description = "ARN of the API Application Load Balancer"
  value       = aws_lb.cca_api_alb.arn
}

output "api_alb_dns_name" {
  description = "DNS name of the API Application Load Balancer"
  value       = aws_lb.cca_api_alb.dns_name
}

output "api_alb_account_target_group_arn" {
  description = "ARN of the API ALB account target group"
  value       = aws_lb_target_group.cca_account_tg.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.cca.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.cca.arn
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.cca.id
}

output "ecs_capacity_provider_name" {
  description = "Name of the ECS capacity provider"
  value       = aws_ecs_capacity_provider.cca_ecs_cp.name
}

output "ecs_capacity_provider_arn" {
  description = "ARN of the ECS capacity provider"
  value       = aws_ecs_capacity_provider.cca_ecs_cp.arn
}

output "ecs_autoscaling_group_name" {
  description = "Name of the ECS Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_asg.name
}

output "ecs_autoscaling_group_arn" {
  description = "ARN of the ECS Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_asg.arn
}

output "ecs_launch_template_id" {
  description = "ID of the ECS launch template"
  value       = aws_launch_template.ecs_lt.id
}

output "ecs_launch_template_latest_version" {
  description = "Latest version of the ECS launch template"
  value       = aws_launch_template.ecs_lt.latest_version
}

output "ecs_instance_security_group_id" {
  description = "Security group ID for ECS instances"
  value       = aws_security_group.ecs_instances.id
}

output "ecs_instance_role_arn" {
  description = "ARN of the ECS instance IAM role"
  value       = aws_iam_role.ecs_instance_role.arn
}

output "ecs_instance_profile_arn" {
  description = "ARN of the ECS instance profile"
  value       = aws_iam_instance_profile.ecs_instance_profile.arn
}

output "services" {
  description = "Map of all ECS services with their details"
  value = {
    for service_name, service in module.services : service_name => {
      service_id          = service.service_id
      service_name        = service.service_name
      task_definition_arn = service.task_definition_arn
      log_group_name      = service.log_group_name
    }
  }
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.cca_https.arn
}

output "app_url" {
  description = "HTTPS URL of the application"
  value       = "https://${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cca_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cca_distribution.arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cca_distribution.domain_name
}

output "http_api_invoke_url" {
  description = "Invoke URL of the HTTP API Gateway (apigatewayv2)"
  value       = "${replace(aws_apigatewayv2_api.cca_api.api_endpoint, "https://", "")}/${aws_apigatewayv2_stage.cca_stage.name}"
}

output "apigateway_api_id" {
  description = "ID of the HTTP API Gateway (apigatewayv2)"
  value       = aws_apigatewayv2_api.cca_api.id
}

output "apigateway_api_endpoint" {
  description = "Full endpoint URL for the HTTP API Gateway"
  value       = aws_apigatewayv2_api.cca_api.api_endpoint
}

output "apigateway_stage" {
  description = "Stage name for the HTTP API Gateway"
  value       = aws_apigatewayv2_stage.cca_stage.name
}

output "apigateway_vpc_link_id" {
  description = "ID of the API Gateway VPC Link"
  value       = aws_apigatewayv2_vpc_link.cca_vpc_link.id
}

output "apigateway_vpc_link_arn" {
  description = "ARN of the API Gateway VPC Link"
  value       = aws_apigatewayv2_vpc_link.cca_vpc_link.arn
}

output "alb_logs_bucket_name" {
  description = "S3 bucket name used for ALB access logs"
  value       = var.alb_access_logs_bucket_name != "" ? var.alb_access_logs_bucket_name : (length(aws_s3_bucket.cca_alb_logs) > 0 ? aws_s3_bucket.cca_alb_logs[0].id : "")
}

output "alb_logs_bucket_arn" {
  description = "S3 bucket ARN used for ALB access logs"
  value       = var.alb_access_logs_bucket_name != "" ? "arn:aws:s3:::${var.alb_access_logs_bucket_name}" : (length(aws_s3_bucket.cca_alb_logs) > 0 ? aws_s3_bucket.cca_alb_logs[0].arn : "")
}
