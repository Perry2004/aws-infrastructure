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

output "ses_email_identity" {
  description = "The verified SES email identity"
  value       = aws_ses_email_identity.do_not_reply.email
}

output "ses_email_identity_arn" {
  description = "ARN of the SES email identity"
  value       = aws_ses_email_identity.do_not_reply.arn
}

output "app_ecr_repositories" {
  description = "List of ECR repositories created for the app"
  value       = [for repo in aws_ecr_repository.app_repositories : repo]
}

output "gha_iam_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}
