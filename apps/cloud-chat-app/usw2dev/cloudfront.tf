resource "aws_ssm_parameter" "cloudfront_header_secret" {
  name        = "/cca/cloudfront_header_secret"
  description = "Secret value for CloudFront to ALB custom header"
  type        = "SecureString"
  value       = "CHANGE_IN_PRODUCTION"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_cloudfront_distribution" "cca_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.app_full_name}"
  default_root_object = ""
  aliases             = ["${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}"]

  # Origin 1: ALB for SSR pages and assets
  origin {
    domain_name = aws_lb.cca_alb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "X-Custom-Header"
      value = aws_ssm_parameter.cloudfront_header_secret.value
    }
  }

  # Origin 2: API Gateway (placeholder for future use)
  #   origin {
  #     domain_name = "placeholder-api-gateway.execute-api.${var.aws_region}.amazonaws.com"
  #     origin_id   = "api-gateway-origin"

  #     custom_origin_config {
  #       http_port              = 80
  #       https_port             = 443
  #       origin_protocol_policy = "https-only"
  #       origin_ssl_protocols   = ["TLSv1.2"]
  #     }

  #     custom_header {
  #       name  = "X-Custom-Header"
  #       value = random_password.cloudfront_secret.result
  #     }
  #   }

  # Behavior 0 (Priority 0): /assets/* - Build artifacts with aggressive caching
  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "alb-origin"

    compress = true

    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  # Behavior 1 (Priority 1): /api/* - API Gateway with no caching
  # ordered_cache_behavior {
  #   path_pattern     = "/api/*"
  #   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods   = ["GET", "HEAD"]
  #   target_origin_id = "api-gateway-origin"

  #   compress = true

  #   viewer_protocol_policy   = "redirect-to-https"
  #   cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
  #   origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  # }

  # Default behavior (*): SSR pages with no caching but passing all viewer info
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"

    compress = true

    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  # SSL/TLS certificate
  viewer_certificate {
    acm_certificate_arn      = data.terraform_remote_state.dns.outputs.wildcard_certificate_arn_us_east_1
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.app_short_name}-cloudfront"
  }
}

# Data sources for managed cache policies
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

# Data sources for managed origin request policies
data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}
