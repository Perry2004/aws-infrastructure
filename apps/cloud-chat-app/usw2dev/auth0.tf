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

# account service client
resource "auth0_client" "cca_account_service" {
  name            = "${var.app_short_name}-account-service"
  description     = "CCA account service client"
  app_type        = "regular_web"
  oidc_conformant = true

  callbacks = [
    "http://localhost:1688/api/v1/account/callback",
    "https://${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}/api/v1/account/callback"
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

resource "auth0_email_provider" "amazon_ses_email_provider" {
  name                 = "ses"
  enabled              = true
  default_from_address = aws_ses_email_identity.do_not_reply.email

  credentials {
    access_key_id     = aws_iam_access_key.auth0_ses.id
    secret_access_key = aws_iam_access_key.auth0_ses.secret
    region            = aws_ses_email_identity.do_not_reply.region
  }
}
