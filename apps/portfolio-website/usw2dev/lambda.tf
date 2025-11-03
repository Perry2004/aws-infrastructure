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

# EventBridge rule to trigger lambda every 3 days
resource "aws_cloudwatch_event_rule" "pexels_scraper_periodic" {
  name                = "pexels-scraper-periodic-trigger"
  description         = "Trigger Pexels image scraper lambda every 3 days"
  schedule_expression = "rate(3 days)"
}

resource "aws_cloudwatch_event_target" "pexels_scraper_lambda" {
  rule      = aws_cloudwatch_event_rule.pexels_scraper_periodic.name
  target_id = "PexelsScraperLambda"
  arn       = aws_lambda_function.pexels_image_scraper.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pexels_image_scraper.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pexels_scraper_periodic.arn
}

