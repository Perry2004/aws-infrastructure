resource "tfe_workspace" "common_iam" {
  name                          = "aws-infrastructure-common-iam-test"
  description                   = "Workspace for the IAM resources in the account"
  auto_apply                    = true
  terraform_version             = "~>1.13.0"
  working_directory             = "common/iam"
  structured_run_output_enabled = true
  speculative_enabled           = true
  project_id                    = "prj-uyhg55vK55nquUJt"
  vcs_repo {
    identifier     = "Perry2004/aws-infrastructure"
    oauth_token_id = var.github_oauth_token
    branch         = "" # default branch
  }
}
