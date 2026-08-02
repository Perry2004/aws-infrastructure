moved {
  from = aws_lightsail_instance.proxy
  to   = module.cli_proxy_api.aws_lightsail_instance.proxy
}

moved {
  from = aws_lightsail_static_ip.proxy
  to   = module.cli_proxy_api.aws_lightsail_static_ip.proxy
}

moved {
  from = aws_lightsail_static_ip_attachment.proxy
  to   = module.cli_proxy_api.aws_lightsail_static_ip_attachment.proxy
}

moved {
  from = aws_lightsail_instance_public_ports.proxy
  to   = module.cli_proxy_api.aws_lightsail_instance_public_ports.proxy
}

moved {
  from = aws_route53_record.proxy_ipv4
  to   = module.cli_proxy_api.aws_route53_record.proxy_ipv4
}

moved {
  from = aws_route53_record.proxy_ipv6
  to   = module.cli_proxy_api.aws_route53_record.proxy_ipv6
}
