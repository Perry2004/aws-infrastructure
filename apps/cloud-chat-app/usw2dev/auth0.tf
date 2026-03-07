# backend resource server
resource "auth0_resource_server" "cca_backend" {
  name                 = "${var.app_short_name}-backend"
  identifier           = "https://${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}/api/"
  signing_alg          = "RS256"
  allow_offline_access = true
}

resource "auth0_resource_server_scopes" "cca_backend_scopes" {
  resource_server_identifier = auth0_resource_server.cca_backend.identifier
  dynamic "scopes" {
    for_each = var.auth0_scopes
    content {
      name        = scopes.value.name
      description = scopes.value.description
    }
  }
}

# account service client
resource "auth0_client" "cca_account_service" {
  name            = "${var.app_short_name}-account-service"
  description     = "CCA account service client"
  app_type        = "regular_web"
  oidc_conformant = true

  callbacks = [
    "http://localhost:8666/api/v1/account/auth/callback",
    "https://${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}/api/v1/account/auth/callback"
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
    "refresh_token",
    "client_credentials"
  ]
}

resource "auth0_client_grant" "cca_account_service_management_api" {
  client_id = auth0_client.cca_account_service.id
  audience  = "https://${var.TFC_AUTH0_DOMAIN}/api/v2/"
  scopes    = ["read:users", "update:users", "delete:users"]
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

resource "auth0_custom_domain" "auth_domain" {
  domain     = "auth.${data.terraform_remote_state.dns.outputs.domain_name}"
  type       = "auth0_managed_certs"
  tls_policy = "recommended"
}

# verification record in dns.tf

resource "auth0_custom_domain_verification" "auth_domain_verification" {
  depends_on       = [aws_route53_record.auth0_custom_domain]
  custom_domain_id = auth0_custom_domain.auth_domain.id
  timeouts { create = "15m" }
}
