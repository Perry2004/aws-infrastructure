resource "aws_route53_zone" "clawbench_subzone" {
  name = "clawbench.${var.domain_name}"
}

resource "aws_route53_record" "clawbench_ns" {
  zone_id = aws_route53_zone.perryz_net_zone.zone_id
  name    = "clawbench.${var.domain_name}"
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.clawbench_subzone.name_servers
}

# MX Record
resource "aws_route53_record" "clawbench_mx" {
  zone_id = aws_route53_zone.clawbench_subzone.zone_id
  name    = ""
  type    = "MX"
  ttl     = "3600"
  records = [
    "10 mailserver.purelymail.com."
  ]
}

# TXT / SPF Record
resource "aws_route53_record" "clawbench_spf" {
  zone_id = aws_route53_zone.clawbench_subzone.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "3600"
  records = [
    "v=spf1 include:_spf.purelymail.com ~all"
  ]
}

# Ownership TXT Record
resource "aws_route53_record" "clawbench_ownership" {
  zone_id = aws_route53_zone.clawbench_subzone.zone_id
  name    = "clawbench.${var.domain_name}"
  type    = "TXT"
  ttl     = "300"
  records = [
    "purelymail_ownership_proof=05ebc6732a9fdf83aaac36fac2bfc3df55b2c5c3a698f16e89086d610c7265e2777f2982e1646833e0eca00f6835ad74dc00b98fde13c4b6e7ab16d4c29032aa"
  ]
}

# DKIM Records
resource "aws_route53_record" "clawbench_dkim_1" {
  zone_id = aws_route53_zone.clawbench_subzone.zone_id
  name    = "purelymail1._domainkey.clawbench.${var.domain_name}"
  type    = "CNAME"
  ttl     = "3600"
  records = ["key1.dkimroot.purelymail.com."]
}

resource "aws_route53_record" "clawbench_dkim_2" {
  zone_id = aws_route53_zone.clawbench_subzone.zone_id
  name    = "purelymail2._domainkey.clawbench.${var.domain_name}"
  type    = "CNAME"
  ttl     = "3600"
  records = ["key2.dkimroot.purelymail.com."]
}

resource "aws_route53_record" "clawbench_dkim_3" {
  zone_id = aws_route53_zone.clawbench_subzone.zone_id
  name    = "purelymail3._domainkey.clawbench.${var.domain_name}"
  type    = "CNAME"
  ttl     = "3600"
  records = ["key3.dkimroot.purelymail.com."]
}

# DMARC Record
resource "aws_route53_record" "clawbench_dmarc" {
  zone_id = aws_route53_zone.clawbench_subzone.zone_id
  name    = "_dmarc.clawbench.${var.domain_name}"
  type    = "CNAME"
  ttl     = "3600"
  records = [
    "dmarcroot.purelymail.com."
  ]
}
