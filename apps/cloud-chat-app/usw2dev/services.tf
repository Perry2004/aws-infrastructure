
locals {
  service_target_group_arns = {
    "ui"                  = aws_lb_target_group.cca_tg.arn
    "api_account-service" = aws_lb_target_group.cca_account_tg.arn
  }
  secrets_arns = {
    for secret_name in var.cca_secrets :
    secret_name => aws_ssm_parameter.cca_secrets[secret_name].arn
  }
}

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
  target_group_arn       = each.value.use_load_balancer ? lookup(local.service_target_group_arns, each.value.service_name, aws_lb_target_group.cca_tg.arn) : null
  desired_count          = each.value.desired_count
  health_check_path      = each.value.health_check_path
  env_vars               = each.value.env_vars
  secrets_arns           = local.secrets_arns
}

resource "aws_ssm_parameter" "cca_secrets" {
  for_each = toset(var.cca_secrets)
  name     = "/${var.app_short_name}/${each.value}"
  type     = "SecureString"
  value    = "DUMMY_VALUE_MANAGED_IN_TERRAFORM"

  lifecycle {
    ignore_changes = [value]
  }
}
