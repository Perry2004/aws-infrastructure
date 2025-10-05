terraform {
  required_version = ">= 1.9.0"

  cloud {
    organization = "perry-zhu-aws"

    workspaces {
      project = "aws"
      name    = "aws-infrastructure-common"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
