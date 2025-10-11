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

  origin {
    domain_name              = aws_s3_bucket.portfolio_website_bucket.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.portfolio_website_bucket.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio_website_oac.id
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
    cloudfront_default_certificate = true # to be changed, test with CloudFront default first
  }
}

