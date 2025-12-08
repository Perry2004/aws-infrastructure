resource "aws_cognito_user_pool" "cca" {
  name = "${var.app_short_name}-user-pool"

  email_configuration {
    from_email_address    = "Cloud-Chat-App <do-not-reply@${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}>"
    email_sending_account = "DEVELOPER"
    source_arn            = aws_ses_email_identity.do_not_reply.arn
  }
}

resource "aws_cognito_user_pool_client" "cca_client" {
  name            = "${var.app_short_name}-client"
  user_pool_id    = aws_cognito_user_pool.cca.id
  generate_secret = true # generate client secret for backend
}
