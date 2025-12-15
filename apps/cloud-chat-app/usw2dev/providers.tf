provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.app_short_name
      Env     = var.env_name
    }
  }
}

provider "mongodbatlas" {
  client_id     = var.TFC_MONGO_ATLAS_CLIENT_ID
  client_secret = var.TFC_MONGO_ATLAS_CLIENT_SECRET
}

provider "auth0" {
  domain        = var.TFC_AUTH0_DOMAIN
  client_id     = var.TFC_AUTH0_CLIENT_ID
  client_secret = var.TFC_AUTH0_CLIENT_SECRET
}
