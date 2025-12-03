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

# http api gateway
resource "aws_apigatewayv2_api" "cca_api" {
  name          = "${var.app_short_name}-http-api"
  protocol_type = "HTTP"
  description   = "HTTP API for ${var.app_full_name} that proxies /api/v1/account to ALB"
}

# log for api gateway access to cloudwatch
resource "aws_cloudwatch_log_group" "apigw_access_logs" {
  count             = var.enable_apigw_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.app_short_name}-${var.env_name}-http-api"
  retention_in_days = var.apigw_access_log_retention_days
  tags = {
    Name = "${var.app_short_name}-http-api-access-logs"
  }
}

resource "aws_cloudwatch_log_resource_policy" "apigw_logs_policy" {
  count = var.enable_apigw_access_logs ? 1 : 0

  policy_name     = "${var.app_short_name}-${var.env_name}-apigw-logs-policy"
  policy_document = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAPIGatewayCloudWatchLogs",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.apigw_access_logs[0].name}:*"
    }
  ]
}
POLICY
}

# integration for account service
resource "aws_apigatewayv2_integration" "account_integration" {
  api_id                 = aws_apigatewayv2_api.cca_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = aws_lb_listener.cca_api_alb_listener.arn
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.cca_vpc_link.id
  payload_format_version = "1.0"
  request_parameters = {
    "overwrite:path" = "/api/v1/account"
  }
}

resource "aws_apigatewayv2_integration" "account_proxy_integration" {
  api_id                 = aws_apigatewayv2_api.cca_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = aws_lb_listener.cca_api_alb_listener.arn
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.cca_vpc_link.id
  payload_format_version = "1.0"
  # This strips the stage name by forcing the path to /api/v1/account/ + whatever follows
  request_parameters = {
    "overwrite:path" = "/api/v1/account/$request.path.proxy"
  }
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

  dynamic "access_log_settings" {
    for_each = var.enable_apigw_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.apigw_access_logs[0].arn
      format = jsonencode({
        requestId          = "$context.requestId",
        ip                 = "$context.identity.sourceIp",
        requestTime        = "$context.requestTime",
        httpMethod         = "$context.httpMethod",
        routeKey           = "$context.routeKey",
        path               = "$context.path",
        status             = "$context.status",
        protocol           = "$context.protocol",
        responseLength     = "$context.responseLength",
        integrationLatency = "$context.integrationLatency"
      })
    }
  }
}
