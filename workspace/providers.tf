provider "tfe" {
  hostname     = "app.terraform.io"
  organization = "perry-zhu-aws"
  token        = var.tfe_token
}
