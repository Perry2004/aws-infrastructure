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
  comment             = "${var.app_full_name} distribution"
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

  # Origin 2: API Gateway
  origin {
    domain_name = replace(aws_apigatewayv2_api.cca_api.api_endpoint, "https://", "")
    origin_id   = "api-gateway-origin"
    origin_path = "/${aws_apigatewayv2_stage.cca_stage.name}"
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

  # Behavior 0 (Priority 0): /assets/* - Build artifacts with aggressive caching
  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "alb-origin"

    compress = true

    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.forward_host.id
  }

  # Behavior 1 (Priority 1): /api/* - API Gateway with no caching
  ordered_cache_behavior {
    path_pattern     = "/api/v1/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway-origin"

    compress = true

    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  # Behavior for the base /api/v1 (exact match)
  ordered_cache_behavior {
    path_pattern     = "/api/v1"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway-origin"

    compress = true

    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

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

# Custom origin request policy to include header forwarding
resource "aws_cloudfront_origin_request_policy" "forward_host" {
  name    = "${var.app_short_name}-forward-host"
  comment = "Origin request policy to forward only the Host header to the origin (preserve original Host for ALB)"

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Host"]
    }
  }

  cookies_config {
    cookie_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}
