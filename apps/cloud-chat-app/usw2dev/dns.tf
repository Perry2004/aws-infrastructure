resource "aws_route53_zone" "chat_subdomain_zone" {
  name = "${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}"
}
