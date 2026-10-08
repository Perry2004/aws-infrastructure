resource "aws_lightsail_instance" "sillytavern" {
  name              = var.instance_name
  availability_zone = var.availability_zone
  blueprint_id      = var.lightsail_blueprint
  bundle_id         = var.lightsail_bundle
  ip_address_type   = "dualstack"

  user_data = templatefile("${path.module}/bootstrap.sh.tftpl", {
    sillytavern_version = var.sillytavern_version
    server_hostname     = var.hostname
  })

  tags = {
    Name = var.instance_name
  }

  lifecycle {
    # Bootstrap changes must not replace an instance containing chat history.
    ignore_changes  = [user_data]
    prevent_destroy = true
  }
}

resource "aws_lightsail_static_ip" "sillytavern" {
  name = "${var.instance_name}-ipv4"
}

resource "aws_lightsail_static_ip_attachment" "sillytavern" {
  static_ip_name = aws_lightsail_static_ip.sillytavern.name
  instance_name  = aws_lightsail_instance.sillytavern.name
}

resource "aws_lightsail_instance_public_ports" "sillytavern" {
  instance_name = aws_lightsail_instance.sillytavern.name

  port_info {
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidrs      = [var.admin_ipv4_cidr]
    ipv6_cidrs = []
  }

  port_info {
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidrs      = ["0.0.0.0/0"]
    ipv6_cidrs = ["::/0"]
  }

  port_info {
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidrs      = ["0.0.0.0/0"]
    ipv6_cidrs = ["::/0"]
  }
}

resource "aws_route53_record" "sillytavern_ipv4" {
  zone_id = var.route53_hosted_zone
  name    = var.hostname
  type    = "A"
  ttl     = 60
  records = [aws_lightsail_static_ip.sillytavern.ip_address]
}

resource "aws_route53_record" "sillytavern_ipv6" {
  zone_id = var.route53_hosted_zone
  name    = var.hostname
  type    = "AAAA"
  ttl     = 60
  records = [aws_lightsail_instance.sillytavern.ipv6_addresses[0]]
}
