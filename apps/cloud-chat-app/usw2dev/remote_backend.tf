terraform {
  required_version = ">= 1.9.0"

  cloud {
    organization = "perry-zhu-aws"

    workspaces {
      project = "aws"
      name    = "cloud-chat-app-usw2dev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.0"
    }
    auth0 = {
      source  = "auth0/auth0"
      version = "~>1.0"
    }
  }
}
