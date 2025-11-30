env_name = "usw2dev"

app_repositories = [
  "ui",
  "api/account-service",
]

ui_service_port = 1688

services = [
  {
    service_name       = "ui"
    ecr_repository_key = "ui"
    container_port     = 1688
    cpu                = "256"
    memory             = "512"
    desired_count      = 1
    use_load_balancer  = true
  },
  {
    service_name       = "api_account-service"
    ecr_repository_key = "api/account-service"
    container_port     = 6666
    cpu                = "256"
    memory             = "512"
    desired_count      = 1
    use_load_balancer  = true
  },
]
