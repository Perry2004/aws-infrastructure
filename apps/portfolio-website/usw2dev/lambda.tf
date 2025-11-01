# ecr repo for lambda container image
resource "aws_ecr_repository" "lambda_container_repo" {
  name                 = "pwp/pexels-image-scraper-lambda"
  image_tag_mutability = "MUTABLE"
}

resource "aws_lambda_function" "pexels_image_scraper" {
  function_name = "pexels_image_scraper"
  role          = aws_iam_role.pexels_image_scraper_lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_container_repo.repository_url}:latest"

  memory_size = 1024
  timeout     = 60

  architectures = ["x86_64"]
}
