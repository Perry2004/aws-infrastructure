data "terraform_remote_state" "iam" {
  backend = "remote"

  config = {
    organization = "perry-zhu-aws"
    workspaces = {
      name = "common-iam"
    }
  }
}
