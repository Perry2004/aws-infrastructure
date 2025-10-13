# resource "aws_lambda_function" "lambda_from_s3" {
#   function_name = "UpdatePexelsImageLinks"
#   role          = aws_iam_role.lambda_exec_role.arn

#   # Reference the S3 object
#   s3_bucket = "your-lambda-deployment-bucket" # Replace with your bucket name
#   s3_key    = "path/to/your/function.zip"     # Replace with the key of your zip file

#   # Handler and runtime configuration
#   handler = "lambda_function.handler" # The entry point in your code
#   runtime = "python3.9"

#   # Optional: Environment variables
#   environment {
#     variables = {
#       GREETING = "Hello from S3"
#     }
#   }
# }
