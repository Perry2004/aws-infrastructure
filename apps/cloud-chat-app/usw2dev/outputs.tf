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
