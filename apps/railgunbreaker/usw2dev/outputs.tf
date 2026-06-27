output "s3_bucket_name" {
  description = "Name of the S3 bucket for the rb website"
  value       = aws_s3_bucket.rb_website_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for the rb website"
  value       = aws_s3_bucket.rb_website_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.rb_website_bucket.bucket_regional_domain_name
}

output "rb_website_github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions with S3 read/write access to the rb bucket and ECR access"
  value       = aws_iam_role.rb_gha_s3_ecr.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.rb_website.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution to access the website"
  value       = aws_cloudfront_distribution.rb_website.domain_name
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the RailGunBreaker custom domain in us-east-1"
  value       = aws_acm_certificate_validation.rb_website.certificate_arn
}

output "acm_certificate_domain_name" {
  description = "Domain name covered by the RailGunBreaker ACM certificate"
  value       = aws_acm_certificate.rb_website.domain_name
}

output "acm_certificate_subject_alternative_names" {
  description = "Subject alternative names covered by the RailGunBreaker ACM certificate"
  value       = aws_acm_certificate.rb_website.subject_alternative_names
}

output "railgunbreaker_icu_acm_certificate_arn" {
  description = "ARN of the pending ACM certificate for railgunbreaker.icu in us-east-1"
  value       = aws_acm_certificate.rb_website_icu.arn
}

output "railgunbreaker_icu_acm_certificate_dns_validation_records" {
  description = "DNS validation CNAME records to create in Cloudflare for the railgunbreaker.icu ACM certificate"
  value = {
    for dvo in aws_acm_certificate.rb_website_icu.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

# output "event_bridge_rule_name" {
#   description = "Name of the EventBridge rule that triggers the Pexels image scraper lambda"
#   value       = aws_cloudwatch_event_rule.pexels_scraper_periodic.name
# }
