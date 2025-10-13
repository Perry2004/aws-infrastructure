resource "aws_lambda_function" "lambda_from_s3" {
  function_name = "UpdatePexelsImageLinks"
  role          = aws_iam_role.lambda_exec_role.arn

  s3_bucket = aws_s3_bucket.portfolio_website_bucket.bucket
  s3_key    = "${var.s3_lambda_prefix}/lambda-function.zip"

  handler       = "lambda-handler.lambda_handler"
  runtime       = "nodejs22.x"
  architectures = ["x86_64"]

  layers = [aws_lambda_layer_version.chromium_layer.arn]
}

resource "aws_lambda_layer_version" "chromium_layer" {
  s3_bucket                = aws_s3_bucket.portfolio_website_bucket.bucket
  s3_key                   = "${var.s3_lambda_prefix}/${var.chromium_layer_zip_name}"
  layer_name               = "chromium-layer"
  compatible_runtimes      = ["nodejs22.x"]
  compatible_architectures = ["x86_64"]
}
