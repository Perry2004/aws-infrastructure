provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.app_name
      Env     = var.env_name
    }
  }
}
