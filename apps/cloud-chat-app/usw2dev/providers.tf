provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = "cca"
      Env     = var.env_name
    }
  }
}
