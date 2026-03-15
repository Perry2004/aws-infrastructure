resource "aws_ecr_repository" "lambda_container_repo" {
  name                 = "gp-news/gp-news-lambda"
  image_tag_mutability = "MUTABLE"
}

resource "aws_lambda_function" "gp_news_lambda" {
  function_name = "gp-news-lambda"
  role          = aws_iam_role.gp_news_lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_container_repo.repository_url}:latest"

  memory_size = 512
  timeout     = 60

  architectures = ["x86_64"]
}
