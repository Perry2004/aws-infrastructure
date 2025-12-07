resource "aws_cognito_user_pool" "cca" {
  name = "${var.app_short_name}-user-pool"

  email_configuration {
    from_email_address    = "Cloud-Chat-App <no-reply@${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}>"
    email_sending_account = "DEVELOPER"
    source_arn            = aws_ses_email_identity.do_not_reply.arn
  }
}
