module "services" {
  source = "../_modules/ecs-service"

  for_each = { for service in var.services : service.service_name => service }

  service_name           = each.value.service_name
  app_short_name         = var.app_short_name
  aws_region             = var.aws_region
  cluster_id             = aws_ecs_cluster.cca.id
  capacity_provider_name = aws_ecs_capacity_provider.cca_ecs_cp.name
  ecr_repository_url     = aws_ecr_repository.app_repositories[each.value.ecr_repository_key].repository_url
  container_port         = each.value.container_port
  cpu                    = each.value.cpu
  memory                 = each.value.memory
  execution_role_arn     = aws_iam_role.ecs_task_execution_role.arn
  target_group_arn       = aws_lb_target_group.cca_tg.arn
  lb_listener_arn        = aws_lb_listener.cca_http.arn
  desired_count          = each.value.desired_count
}
