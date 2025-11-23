resource "aws_security_group" "cca_alb_sg" {
  name        = "${var.app_short_name}-alb-sg"
  description = "Security group for Cloud Chat App ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_short_name}-alb-sg"
  }
}

resource "aws_lb" "cca_alb" {
  name               = "${var.app_short_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cca_alb_sg.id]
  subnets = [
    aws_subnet.cca_public_a.id,
    aws_subnet.cca_public_b.id
  ]
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.app_short_name}-alb"
  }
}

resource "aws_lb_target_group" "cca_tg" {
  name     = "${var.app_short_name}-tg"
  port     = var.ui_service_port
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.app_short_name}-tg"
  }
}

resource "aws_lb_listener" "cca_http" {
  load_balancer_arn = aws_lb.cca_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cca_tg.arn
  }
}
