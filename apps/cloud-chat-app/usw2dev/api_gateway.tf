resource "aws_apigatewayv2_vpc_link" "cca_vpc_link" {
  name               = "${var.app_short_name}-http-apigw-vpclink"
  security_group_ids = [aws_security_group.cca_apigw_vpclink_sg.id]
  subnet_ids         = [aws_subnet.cca_private_a.id, aws_subnet.cca_private_b.id]
  tags = {
    Name = "${var.app_short_name}-http-apigw-vpclink"
  }
}

resource "aws_security_group" "cca_apigw_vpclink_sg" {
  name        = "${var.app_short_name}-apigw-vpclink-sg"
  description = "Security group for API Gateway VPC Link ENIs"
  vpc_id      = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  egress {
    description = "Allow outbound to account service port"
    from_port   = 6666
    to_port     = 6666
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.cca_private_a.cidr_block,
      aws_subnet.cca_private_b.cidr_block
    ]
  }

  egress {
    description = "Allow outbound to ALB listener port for API Gateway VPC link"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.cca_private_a.cidr_block,
      aws_subnet.cca_private_b.cidr_block
    ]
  }

  tags = {
    Name = "${var.app_short_name}-apigw-vpclink-sg"
  }
}

resource "aws_apigatewayv2_api" "cca_api" {
  name          = "${var.app_short_name}-http-api"
  protocol_type = "HTTP"
  description   = "HTTP API for ${var.app_full_name} that proxies /api/v1/account to ALB"
}

resource "aws_apigatewayv2_integration" "account_integration" {
  api_id                 = aws_apigatewayv2_api.cca_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = aws_lb_listener.cca_api_alb_listener.arn
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.cca_vpc_link.id
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_integration" "account_proxy_integration" {
  api_id                 = aws_apigatewayv2_api.cca_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = aws_lb_listener.cca_api_alb_listener.arn
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.cca_vpc_link.id
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "account_route" {
  api_id    = aws_apigatewayv2_api.cca_api.id
  route_key = "ANY /api/v1/account"
  target    = "integrations/${aws_apigatewayv2_integration.account_integration.id}"
}

resource "aws_apigatewayv2_route" "account_proxy_route" {
  api_id    = aws_apigatewayv2_api.cca_api.id
  route_key = "ANY /api/v1/account/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.account_proxy_integration.id}"
}

resource "aws_apigatewayv2_stage" "cca_stage" {
  api_id      = aws_apigatewayv2_api.cca_api.id
  name        = var.env_name
  auto_deploy = true
}

// NOTE: Moved invocation URL and other API outputs to `outputs.tf` for centralised module outputs

