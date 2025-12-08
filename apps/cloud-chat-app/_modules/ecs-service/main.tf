resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${var.app_short_name}/${var.service_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.app_short_name}-${var.service_name}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = var.cpu
  memory                   = var.memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${var.ecr_repository_url}:latest"
      essential = true
      cpu       = 0
      memory    = tonumber(var.memory)
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 0 # enable dynamic port mapping
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [for key, value in var.env_vars : {
        name  = key
        value = value
      }]
      secrets = [for secret_name, secret_arn in var.secrets_arns : {
        name      = secret_name
        valueFrom = secret_arn
      }]
    }
  ])

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.app_short_name}-${var.service_name}-task"
  }
}

resource "aws_ecs_service" "service" {
  name                               = "${var.app_short_name}-${var.service_name}-svc"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.service.arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 1
    base              = 0
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  enable_execute_command = true

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_cloudwatch_log_group.service
  ]

  tags = {
    Name = "${var.app_short_name}-${var.service_name}-service"
  }
}
