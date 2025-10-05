output "workspace_id" {
  value       = tfe_workspace.common_iam.id
  description = "The ID of the created Terraform Cloud workspace"
}
