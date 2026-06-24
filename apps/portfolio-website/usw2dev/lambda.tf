# ecr repo for lambda container image
resource "aws_ecr_repository" "lambda_container_repo" {
  name                 = "${var.project_name}/pexels-image-scraper-lambda"
  image_tag_mutability = "MUTABLE"
}

resource "aws_lambda_function" "pexels_image_scraper" {
  function_name = "${var.project_name}-pexels-image-scraper"
  role          = aws_iam_role.pexels_image_scraper_lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_container_repo.repository_url}:latest"

  memory_size = 1024
  timeout     = 60

  architectures = ["x86_64"]

  image_config {
    entry_point       = ["/usr/local/bin/npx", "aws-lambda-ric"]
    command           = ["lambda-handler.handler"]
    working_directory = "/app"
  }

  environment {
    variables = {
      PEXELS_FEATURED_UPLOADS_URL  = var.pexels_url
      S3_BUCKET_NAME               = aws_s3_bucket.portfolio_website_bucket.bucket
      S3_OBJECT_KEY                = "${var.s3_website_prefix}/data/rolling-images.json"
      CLOUDFRONT_DISTRIBUTION_ID   = aws_cloudfront_distribution.portfolio_website.id
      CLOUDFRONT_INVALIDATION_PATH = "/data/rolling-images.json"
    }
  }
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
