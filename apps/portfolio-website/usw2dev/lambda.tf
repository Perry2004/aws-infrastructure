# ecr repo for lambda container image
resource "aws_ecr_repository" "lambda_container_repo" {
  name                 = "pwp/pexels-image-scraper-lambda"
  image_tag_mutability = "MUTABLE"
}
