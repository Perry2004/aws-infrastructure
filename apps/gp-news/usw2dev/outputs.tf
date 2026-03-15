output "lambda_ecr_repository_url" {
  description = "The URL of the ECR repository for the Lambda function"
  value       = aws_ecr_repository.lambda_container_repo.repository_url
}

output "lambda_ecr_repository_arn" {
  description = "The ARN of the ECR repository for the Lambda function"
  value       = aws_ecr_repository.lambda_container_repo.arn
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.gp_news_lambda.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.gp_news_lambda.function_name
}

output "gha_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.gp_news_gha_ecr.arn
}

