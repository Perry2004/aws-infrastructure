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

output "ui_service_name" {
  description = "Name of the UI ECS service"
  value       = aws_ecs_service.ui.name
}

output "ui_service_arn" {
  description = "ARN of the UI ECS service"
  value       = aws_ecs_service.ui.id
}

output "ui_service_task_arn" {
  description = "ARN of the UI task definition"
  value       = aws_ecs_task_definition.ui.arn
}

output "ui_log_group_name" {
  description = "Name of the CloudWatch log group for UI service"
  value       = aws_cloudwatch_log_group.ui.name
}
