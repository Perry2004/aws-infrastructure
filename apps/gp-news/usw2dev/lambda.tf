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

resource "aws_cloudwatch_event_rule" "gp_news_periodic" {
  count = length(var.schedule_daily_utc_time)

  name                = "gp-news-scraper-periodic-trigger-${count.index}"
  description         = "Trigger GP News scraper lambda daily at ${var.schedule_daily_utc_time[count.index]} UTC"
  schedule_expression = "cron(${split(":", var.schedule_daily_utc_time[count.index])[1]} ${split(":", var.schedule_daily_utc_time[count.index])[0]} * * ? *)"
}

resource "aws_cloudwatch_event_target" "gp_news_scraper_lambda" {
  count = length(var.schedule_daily_utc_time)

  rule      = aws_cloudwatch_event_rule.gp_news_periodic[count.index].name
  target_id = "GPNewsScraperLambda-${count.index}"
  arn       = aws_lambda_function.gp_news_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count = length(var.schedule_daily_utc_time)

  statement_id  = "AllowExecutionFromEventBridge-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gp_news_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.gp_news_periodic[count.index].arn
}

