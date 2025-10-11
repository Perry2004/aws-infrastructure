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
  description = "ARN of the IAM role for GitHub Actions with S3 read/write access to the pwp bucket"
  value       = aws_iam_role.pwp_gha_s3.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.portfolio_website.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution to access the website"
  value       = aws_cloudfront_distribution.portfolio_website.domain_name
}
