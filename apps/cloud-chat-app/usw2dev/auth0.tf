# backend resource server
resource "auth0_resource_server" "cca_backend" {
  name        = "${var.app_short_name}-backend"
  identifier  = "https://${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}/api/"
  signing_alg = "RS256"

}

resource "auth0_resource_server_scopes" "cca_backend_scopes" {
  resource_server_identifier = auth0_resource_server.cca_backend.identifier
  for_each                   = { for scope in var.auth0_scopes : scope.name => scope }
  scopes {
    name        = each.value.name
    description = each.value.description
  }
}

# frontend client
resource "auth0_client" "cca_frontend" {
  name            = "${var.app_short_name}-frontend"
  description     = "CCA Tanstack Start frontend client"
  app_type        = "regular_web"
  oidc_conformant = true

  callbacks = [
    "http://localhost:1688/api/auth/callback",
    "https://${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}/api/auth/callback"
  ]

  allowed_logout_urls = [
    "http://localhost:1688",
    "https://${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}/"
  ]

  web_origins = [
    "http://localhost:1688",
    "https://${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}"
  ]

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 3600 # 1 hour access token
  }

  grant_types = [
    "authorization_code",
    "refresh_token"
  ]
}
