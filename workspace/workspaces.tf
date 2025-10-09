data "tfe_project" "this" {
  name         = "aws"
  organization = var.organization_name
}

data "tfe_oauth_client" "github" {
  service_provider = "github"
  organization     = var.organization_name
}

locals {
  workspaces = yamldecode(file("${path.module}/datasource/workspaces.yml"))
}

resource "tfe_workspace" "workspaces" {
  for_each = { for ws in local.workspaces.workspaces : ws.name => ws }

  name                          = each.value.name
  description                   = each.value.description
  working_directory             = each.value.working_directory
  auto_apply                    = true
  terraform_version             = "~>1.13.0"
  speculative_enabled           = true
  structured_run_output_enabled = true
  project_id                    = data.tfe_project.this.id
  trigger_patterns              = try(each.value.trigger_patterns, [])


  vcs_repo {
    identifier     = "Perry2004/aws-infrastructure"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
    branch         = "" # default branch
  }
}

resource "tfe_workspace_settings" "workspace_settings" {
  for_each = tfe_workspace.workspaces

  workspace_id        = each.value.id
  global_remote_state = true
}
