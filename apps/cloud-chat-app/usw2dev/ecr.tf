locals {
  app_repositories_object = {
    for repo in var.app_repositories : repo => "${var.app_short_name}/${repo}"
  }
}

resource "aws_ecr_repository" "app_repositories" {
  for_each = local.app_repositories_object

  name                 = each.value
  image_tag_mutability = "MUTABLE"
}
