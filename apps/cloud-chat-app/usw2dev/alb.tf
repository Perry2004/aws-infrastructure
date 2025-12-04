data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "cca_alb_sg" {
  name        = "${var.app_short_name}-alb-sg"
  description = "Security group for Cloud Chat App ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  ingress {
    description     = "HTTPS from CloudFront"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  egress {
    description = "HTTP to UI service on dynamic ports"
    from_port   = 32768
    to_port     = 61000
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.cca_private_a.cidr_block,
      aws_subnet.cca_private_b.cidr_block
    ]
  }

  tags = {
    Name = "${var.app_short_name}-alb-sg"
  }
}

# alb between the cloudfront and the UI service
resource "aws_lb" "cca_alb" {
  name               = "${var.app_short_name}-ui-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cca_alb_sg.id]
  subnets = [
    aws_subnet.cca_public_a.id,
    aws_subnet.cca_public_b.id
  ]
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  access_logs {
    enabled = var.enable_alb_access_logs
    bucket  = var.alb_access_logs_bucket_name != "" ? var.alb_access_logs_bucket_name : aws_s3_bucket.cca_alb_logs[0].id
    prefix  = var.alb_access_logs_bucket_prefix
  }

  tags = {
    Name = "${var.app_short_name}-ui-alb"
  }
}

resource "aws_lb_target_group" "cca_tg" {
  name_prefix = "${var.app_short_name}-"
  protocol    = "HTTP"
  target_type = "instance"
  port        = 3000 # dummy port, actual port is dynamic ephemeral port
  vpc_id      = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.app_short_name}-tg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# sg for the internal alb after the API Gateway
resource "aws_security_group" "cca_api_alb_sg" {
  name        = "${var.app_short_name}-api-alb-sg"
  description = "Security group for internal API Application Load Balancer"
  vpc_id      = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  ingress {
    description     = "HTTP from API Gateway VPC Link ENIs"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.cca_apigw_vpclink_sg.id]
  }

  ingress {
    description = "Allow HTTP from private subnets so ALB can be reached internally"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.cca_private_a.cidr_block,
      aws_subnet.cca_private_b.cidr_block
    ]
  }

  egress {
    description = "Allow outbound to private subnets ephemeral ports"
    from_port   = 32768
    to_port     = 61000
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.cca_private_a.cidr_block,
      aws_subnet.cca_private_b.cidr_block
    ]
  }

  tags = {
    Name = "${var.app_short_name}-api-alb-sg"
  }
}

# internal alb after the API Gateway
resource "aws_lb" "cca_api_alb" {
  name               = "${var.app_short_name}-api-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cca_api_alb_sg.id]
  subnets = [
    aws_subnet.cca_private_a.id,
    aws_subnet.cca_private_b.id,
  ]

  enable_http2                     = false
  enable_cross_zone_load_balancing = true

  access_logs {
    enabled = var.enable_alb_access_logs
    bucket  = var.alb_access_logs_bucket_name != "" ? var.alb_access_logs_bucket_name : aws_s3_bucket.cca_alb_logs[0].id
    prefix  = var.alb_access_logs_bucket_prefix
  }

  tags = {
    Name = "${var.app_short_name}-api-alb"
  }
}

resource "aws_lb_target_group" "cca_account_tg" {
  name_prefix = "${var.app_short_name}-a-"
  protocol    = "HTTP"
  target_type = "instance"
  port        = 6000 # dummy port, actual port is dynamic ephemeral port
  vpc_id      = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/v1/account/health"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.app_short_name}-account-tg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 404 for unmatched routes
resource "aws_lb_listener" "cca_api_alb_listener" {
  load_balancer_arn = aws_lb.cca_api_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# forward /api/v1/account* to the account service target group
resource "aws_lb_listener_rule" "api_account_forward" {
  listener_arn = aws_lb_listener.cca_api_alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cca_account_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/account*", "/api/v1/account"]
    }
  }
}

# ensure https after the cloudfront
resource "aws_lb_listener" "cca_https" {
  load_balancer_arn = aws_lb.cca_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.terraform_remote_state.dns.outputs.wildcard_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

# allow only requests from the cloudfront by verifying the custom header
resource "aws_lb_listener_rule" "verify_cloudfront_header" {
  listener_arn = aws_lb_listener.cca_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cca_tg.arn
  }

  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = [aws_ssm_parameter.cloudfront_header_secret.value]
    }
  }
}
