terraform {
  required_version = ">= 1.9.0"

  cloud {
    organization = "perry-zhu-aws"

    workspaces {
      project = "aws"
      name    = "terraform-workspaces"
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.70.0"
    }
  }
}
