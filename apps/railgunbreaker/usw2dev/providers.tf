provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = "rb-website"
      Env     = var.env_name
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  default_tags {
    tags = {
      Project = "rb-website"
      Env     = var.env_name
    }
  }
}
