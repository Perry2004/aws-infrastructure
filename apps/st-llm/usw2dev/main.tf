locals {
  fqdn = "${var.subdomain_name}.${data.terraform_remote_state.dns.outputs.domain_name}"
}

module "sillytavern" {
  source = "../_modules/sillytavern"

  instance_name       = "${var.project_name}-${var.env_name}"
  availability_zone   = var.availability_zone
  lightsail_blueprint = var.lightsail_blueprint_id
  lightsail_bundle    = var.lightsail_bundle_id
  admin_ipv4_cidr     = var.admin_ipv4_cidr
  sillytavern_version = var.sillytavern_version
  hostname            = local.fqdn
  route53_hosted_zone = data.terraform_remote_state.dns.outputs.domain_hosted_zone_id
}
