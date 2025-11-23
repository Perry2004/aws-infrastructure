resource "aws_ecs_cluster" "cca" {
  name = "${var.app_short_name}-cluster-01"
}

resource "aws_ecs_cluster_capacity_providers" "cca" {
  cluster_name = aws_ecs_cluster.cca.name

  capacity_providers = [aws_ecs_capacity_provider.cca_ecs_cp.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.cca_ecs_cp.name
  }
}

resource "aws_ecs_capacity_provider" "cca_ecs_cp" {
  name = "${var.app_short_name}-ecs-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.app_short_name}-ecs-asg"
  vpc_zone_identifier = [aws_subnet.cca_private_a.id, aws_subnet.cca_private_b.id]
  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "${var.app_short_name}-ecs-lt-"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = "t4g.small"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.ecs_instances.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.cca.name} >> /etc/ecs/ecs.config
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.app_short_name}-ecs-instance"
    }
  }
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/arm64/recommended/image_id"
}

resource "aws_security_group" "ecs_instances" {
  name        = "${var.app_short_name}-ecs-instances-sg"
  description = "Security group for CCA ECS instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = var.ui_service_port
    to_port         = var.ui_service_port
    protocol        = "tcp"
    security_groups = [aws_security_group.cca_alb_sg.id]
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.app_short_name}-ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.app_short_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}
