data "terraform_remote_state" "iam" {
  backend = "remote"

  config = {
    organization = "perry-zhu-aws"
    workspaces = {
      name = "common-iam"
    }
  }
}

data "terraform_remote_state" "dns" {
  backend = "remote"

  config = {
    organization = "perry-zhu-aws"
    workspaces = {
      name = "common-dns"
    }
  }
}
