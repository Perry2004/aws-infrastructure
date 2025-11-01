output "s3_bucket_name" {
  description = "Name of the S3 bucket for the portfolio website"
  value       = aws_s3_bucket.portfolio_website_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for the portfolio website"
  value       = aws_s3_bucket.portfolio_website_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.portfolio_website_bucket.bucket_regional_domain_name
}

output "portfolio_website_github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions with S3 read/write access to the pwp bucket and ECR access"
  value       = aws_iam_role.pwp_gha_s3_ecr.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.portfolio_website.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution to access the website"
  value       = aws_cloudfront_distribution.portfolio_website.domain_name
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the custom domain"
  value       = aws_acm_certificate.portfolio_website_cert.arn
}

output "acm_certificate_domain_name" {
  description = "Domain name covered by the ACM certificate"
  value       = aws_acm_certificate.portfolio_website_cert.domain_name
}

output "acm_certificate_subject_alternative_names" {
  description = "Subject alternative names covered by the ACM certificate"
  value       = aws_acm_certificate.portfolio_website_cert.subject_alternative_names
}

output "lambda_ecr_repository_url" {
  description = "URL of the ECR repository for the lambda container image"
  value       = aws_ecr_repository.lambda_container_repo.repository_url
}

output "lambda_ecr_repository_arn" {
  description = "ARN of the ECR repository for the lambda container image"
  value       = aws_ecr_repository.lambda_container_repo.arn
}
