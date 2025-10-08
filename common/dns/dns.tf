import {
  to = aws_route53domains_registered_domain.perryz_net
  id = var.domain_name
}

resource "aws_route53domains_registered_domain" "perryz_net" {
  domain_name = var.domain_name

  name_server {
    name = aws_route53_zone.perryz_net_zone.name_servers[0]
  }
  name_server {
    name = aws_route53_zone.perryz_net_zone.name_servers[1]
  }
  name_server {
    name = aws_route53_zone.perryz_net_zone.name_servers[2]
  }
  name_server {
    name = aws_route53_zone.perryz_net_zone.name_servers[3]
  }
}

resource "aws_route53_zone" "perryz_net_zone" {
  name = var.domain_name
}
