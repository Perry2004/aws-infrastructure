# resource "aws_lambda_function" "lambda_from_s3" {
#   function_name = "UpdatePexelsImageLinks"
#   role          = aws_iam_role.lambda_exec_role.arn

#   s3_bucket = aws_s3_bucket.portfolio_website_bucket.bucket
#   s3_key    = "${var.s3_lambda_prefix}/lambda-function.zip"

#   handler          = "lambda-handler.lambdaHandler"
#   runtime          = "nodejs22.x"
#   architectures    = ["x86_64"]
#   source_code_hash = data.aws_s3_object.lambda_zip.etag

#   layers = [aws_lambda_layer_version.chromium_layer.arn]
# }

# data "aws_s3_object" "lambda_zip" {
#   bucket = aws_s3_bucket.portfolio_website_bucket.bucket
#   key    = "${var.s3_lambda_prefix}/lambda-function.zip"
# }

# resource "aws_lambda_layer_version" "chromium_layer" {
#   s3_bucket                = aws_s3_bucket.portfolio_website_bucket.bucket
#   s3_key                   = "${var.s3_lambda_prefix}/${var.chromium_layer_zip_name}"
#   layer_name               = "chromium-layer"
#   compatible_runtimes      = ["nodejs22.x"]
#   compatible_architectures = ["x86_64"]
#   source_code_hash         = data.aws_s3_object.chromium_layer_zip.etag
# }

# data "aws_s3_object" "chromium_layer_zip" {
#   bucket = aws_s3_bucket.portfolio_website_bucket.bucket
#   key    = "${var.s3_lambda_prefix}/${var.chromium_layer_zip_name}"
# }

# ecr repo for lambda container image
resource "aws_ecr_repository" "lambda_container_repo" {
  name                 = "pwp/pexels-image-scraper-lambda"
  image_tag_mutability = "MUTABLE"
}
