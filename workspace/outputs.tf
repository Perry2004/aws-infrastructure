output "workspace_info" {
  value       = { for k, v in tfe_workspace.workspaces : k => { id = v.id, name = v.name, working_directory = v.working_directory } }
  description = "Map of workspace names to their Terraform Cloud workspace information"
}

output "project_id" {
  value       = data.tfe_project.this.id
  description = "Terraform Cloud project ID"
}

output "oauth_client_id" {
  value       = data.tfe_oauth_client.github.id
  description = "OAuth client ID for GitHub"
}
