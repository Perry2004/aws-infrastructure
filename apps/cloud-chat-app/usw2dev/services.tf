resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_short_name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ui" {
  family                   = "${var.app_short_name}-ui"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "ui"
      image     = "${aws_ecr_repository.app_repositories["ui"].repository_url}:latest"
      essential = true
      cpu       = 0
      memory    = 512
      portMappings = [
        {
          containerPort = var.ui_service_port
          hostPort      = var.ui_service_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.app_short_name}-ui"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.app_short_name}-ui-task"
  }
}

resource "aws_cloudwatch_log_group" "ui" {
  name              = "/ecs/${var.app_short_name}-ui"
  retention_in_days = 7
}

resource "aws_ecs_service" "ui" {
  name                               = "${var.app_short_name}-ui-svc"
  cluster                            = aws_ecs_cluster.cca.id
  task_definition                    = aws_ecs_task_definition.ui.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cca_ecs_cp.name
    weight            = 1
    base              = 0
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cca_tg.arn
    container_name   = "ui"
    container_port   = var.ui_service_port
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_lb_listener.cca_http,
    aws_cloudwatch_log_group.ui
  ]

  tags = {
    Name = "${var.app_short_name}-ui-service"
  }
}

