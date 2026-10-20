data "terraform_remote_state" "dns" {
  backend = "remote"

  config = {
    organization = "perry-zhu-aws"
    workspaces = {
      name = "common-dns"
    }
  }
}
