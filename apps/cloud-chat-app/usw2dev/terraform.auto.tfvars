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
    health_check_path  = "/health"
    env_vars = {
      "dummy" = "value"
    }
  },
  {
    service_name       = "api_account-service"
    ecr_repository_key = "api/account-service"
    container_port     = 8666
    cpu                = "256"
    memory             = "512"
    desired_count      = 1
    use_load_balancer  = true
    health_check_path  = "/api/v1/account/health"
    env_vars = {
      "dummy" = "value"
    }
  },
]

cca_secrets = [
  "mongo_client_id",
  "mongo_client"
]

auth0_scopes = [{
  name        = "dummy:one"
  description = "dummy scope one"
  }, {
  name        = "dummy:two"
  description = "dummy scope two"
}]
