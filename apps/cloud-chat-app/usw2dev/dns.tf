resource "aws_route53_record" "ses_verification" {
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.chat_domain.domain}"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.chat_domain.verification_token]
}

resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = "${aws_ses_domain_dkim.chat_domain.dkim_tokens[count.index]}._domainkey.${aws_ses_domain_identity.chat_domain.domain}"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_ses_domain_dkim.chat_domain.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses_spf" {
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = aws_ses_domain_identity.chat_domain.domain
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "ses_dmarc" {
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = "_dmarc.${aws_ses_domain_identity.chat_domain.domain}"
  type    = "TXT"
  ttl     = 600
  records = ["v=DMARC1; p=quarantine; rua=mailto:do-not-reply@${aws_ses_domain_identity.chat_domain.domain}"]
}

resource "aws_route53_record" "chat_alias" {
  zone_id = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
  name    = "${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.cca_alb.dns_name
    zone_id                = aws_lb.cca_alb.zone_id
    evaluate_target_health = true
  }
}
