# Purelymail DNS records for clawbench.perryz.net

# MX record
resource "aws_route53_record" "clawbench_mx" {
  zone_id = aws_route53_zone.perryz_net_zone.zone_id
  name    = "clawbench.${var.domain_name}"
  type    = "MX"
  ttl     = 3600
  records = ["10 mailserver.purelymail.com."]
}

# SPF record
resource "aws_route53_record" "clawbench_spf" {
  zone_id = aws_route53_zone.perryz_net_zone.zone_id
  name    = "clawbench.${var.domain_name}"
  type    = "TXT"
  ttl     = 3600
  records = [
    "v=spf1 include:_spf.purelymail.com ~all",
    "purelymail_ownership_proof=05ebc6732a9fdf83aaac36fac2bfc3df55b2c5c3a698f16e89086d610c7265e2777f2982e1646833e0eca00f6835ad74dc00b98fde13c4b6e7ab16d4c29032aa",
  ]
}

# DKIM records
resource "aws_route53_record" "clawbench_dkim1" {
  zone_id = aws_route53_zone.perryz_net_zone.zone_id
  name    = "purelymail1._domainkey.clawbench.${var.domain_name}"
  type    = "CNAME"
  ttl     = 3600
  records = ["key1.dkimroot.purelymail.com."]
}

resource "aws_route53_record" "clawbench_dkim2" {
  zone_id = aws_route53_zone.perryz_net_zone.zone_id
  name    = "purelymail2._domainkey.clawbench.${var.domain_name}"
  type    = "CNAME"
  ttl     = 3600
  records = ["key2.dkimroot.purelymail.com."]
}

resource "aws_route53_record" "clawbench_dkim3" {
  zone_id = aws_route53_zone.perryz_net_zone.zone_id
  name    = "purelymail3._domainkey.clawbench.${var.domain_name}"
  type    = "CNAME"
  ttl     = 3600
  records = ["key3.dkimroot.purelymail.com."]
}

# DMARC record
resource "aws_route53_record" "clawbench_dmarc" {
  zone_id = aws_route53_zone.perryz_net_zone.zone_id
  name    = "_dmarc.clawbench.${var.domain_name}"
  type    = "CNAME"
  ttl     = 3600
  records = ["dmarcroot.purelymail.com."]
}
