# SSL certificate
resource "aws_acm_certificate" "portfolio_website_cert" {
  provider                  = aws.us-east-1
  domain_name               = data.terraform_remote_state.dns.outputs.domain_name
  subject_alternative_names = ["www.${data.terraform_remote_state.dns.outputs.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation records for ACM certificate
resource "aws_route53_record" "portfolio_website_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.portfolio_website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "portfolio_website_cert_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.portfolio_website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.portfolio_website_cert_validation : record.fqdn]
}

# DNS alias record to route domain to CloudFront distribution
resource "aws_route53_record" "portfolio_website_alias" {
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = data.terraform_remote_state.dns.outputs.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_website.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_website.hosted_zone_id
    evaluate_target_health = false
  }
}

# IPv6 AAAA record
resource "aws_route53_record" "portfolio_website_alias_ipv6" {
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = data.terraform_remote_state.dns.outputs.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_website.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_website.hosted_zone_id
    evaluate_target_health = false
  }
}

# DNS alias record to route www subdomain to CloudFront distribution
resource "aws_route53_record" "portfolio_website_www_alias" {
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = "www.${data.terraform_remote_state.dns.outputs.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_website.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_website.hosted_zone_id
    evaluate_target_health = false
  }
}

# IPv6 AAAA record for www subdomain
resource "aws_route53_record" "portfolio_website_www_alias_ipv6" {
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = "www.${data.terraform_remote_state.dns.outputs.domain_name}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_website.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_website.hosted_zone_id
    evaluate_target_health = false
  }
}

# Origin Access Control to allow CloudFront to access private S3 bucket
resource "aws_cloudfront_origin_access_control" "portfolio_website_oac" {
  name                              = "PortfolioWebsiteOAC"
  description                       = "Origin Access Control for portfolio website S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "portfolio_website" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Portfolio website distribution"
  default_root_object = "index.html"
  aliases             = [data.terraform_remote_state.dns.outputs.domain_name, "www.${data.terraform_remote_state.dns.outputs.domain_name}"]

  origin {
    domain_name              = aws_s3_bucket.portfolio_website_bucket.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.portfolio_website_bucket.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio_website_oac.id
    origin_path              = "/${var.s3_website_prefix}"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.portfolio_website_bucket.bucket}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.portfolio_website_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "PortfolioWebsite-CloudFront-${var.env_name}"
  }

  depends_on = [aws_acm_certificate_validation.portfolio_website_cert_validation]

  lifecycle {
    create_before_destroy = true
  }
}
