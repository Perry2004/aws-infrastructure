resource "aws_ses_domain_identity" "chat_domain" {
  domain = "${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}"
}

resource "aws_ses_domain_dkim" "chat_domain" {
  domain = aws_ses_domain_identity.chat_domain.domain
}
