# Public ECR repository for lambda container image
resource "aws_ecrpublic_repository" "lambda_container_repo" {
  provider        = aws.us-east-1
  repository_name = "pexels-image-scraper-lambda"

  catalog_data {
    description = "Public repository for Pexels image scraper lambda container"
    about_text  = "Container image for AWS Lambda function that scrapes images from Pexels"
  }
}
