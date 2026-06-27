locals {
  rb_website_icu_domain_name     = var.custom_domain_name
  rb_website_icu_www_domain_name = var.custom_www_domain_name
  rb_website_domain_aliases      = [local.rb_website_icu_domain_name, local.rb_website_icu_www_domain_name]
}

resource "aws_acm_certificate" "rb_website_icu" {
  provider                  = aws.us-east-1
  domain_name               = local.rb_website_icu_domain_name
  subject_alternative_names = [local.rb_website_icu_www_domain_name]
  validation_method         = "DNS"

  tags = {
    Name = "rbWebsite-ICU-Certificate-${var.env_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Origin Access Control to allow CloudFront to access private S3 bucket
resource "aws_cloudfront_origin_access_control" "rb_website_oac" {
  name                              = "rbWebsiteOAC"
  description                       = "Origin Access Control for rb website S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "rb_website" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "rb website distribution"
  default_root_object = "index.html"
  aliases             = local.rb_website_domain_aliases

  origin {
    domain_name              = aws_s3_bucket.rb_website_bucket.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.rb_website_bucket.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.rb_website_oac.id
    origin_path              = "/${var.s3_website_prefix}"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.rb_website_bucket.bucket}"
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
    acm_certificate_arn      = aws_acm_certificate.rb_website_icu.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "rbWebsite-CloudFront-${var.env_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
