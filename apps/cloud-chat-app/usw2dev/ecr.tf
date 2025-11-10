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

resource "aws_ecr_lifecycle_policy" "app_repositories_lifecycle" {
  for_each   = local.app_repositories_object
  repository = aws_ecr_repository.app_repositories[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after 3 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
