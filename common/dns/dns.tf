import {
  to = aws_route53domains_registered_domain.perryz_net
  id = var.domain_name
}

resource "aws_route53domains_registered_domain" "perryz_net" {
  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_zone.perryz_net_zone.name_servers
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_zone" "perryz_net_zone" {
  name = var.domain_name
}
