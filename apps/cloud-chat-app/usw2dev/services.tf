module "ui_service" {
  source = "../_modules/ecs-service"

  service_name           = "ui"
  app_short_name         = var.app_short_name
  aws_region             = var.aws_region
  cluster_id             = aws_ecs_cluster.cca.id
  capacity_provider_name = aws_ecs_capacity_provider.cca_ecs_cp.name
  ecr_repository_url     = aws_ecr_repository.app_repositories["ui"].repository_url
  container_port         = var.ui_service_port
  cpu                    = "256"
  memory                 = "512"
  execution_role_arn     = aws_iam_role.ecs_task_execution_role.arn
  target_group_arn       = aws_lb_target_group.cca_tg.arn
  lb_listener_arn        = aws_lb_listener.cca_http.arn
  desired_count          = 1
}


