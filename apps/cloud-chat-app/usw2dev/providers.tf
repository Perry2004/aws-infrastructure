provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.app_short_name
      Env     = var.env_name
    }
  }
}
