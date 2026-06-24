# allow website GHA to push build artifacts to S3
resource "aws_iam_role" "rb_gha_s3_ecr" {
  name = "rb-GHA-S3-ECR-ReadWrite"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.terraform_remote_state.iam.outputs.github_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "rb_gha" {
  name        = "ReadWrite-rbWebsite-S3-ECR"
  description = "Allow the rb website GitHub Actions to update the latest build artifacts in S3 and ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3List"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.rb_website_bucket.arn
        ]
      },
      {
        Sid    = "AllowS3ReadWrite"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.rb_website_bucket.arn}/*"
        ]
      },
      {
        Sid    = "AllowCloudFrontInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation"
        ]
        Resource = [
          aws_cloudfront_distribution.rb_website.arn
        ]
      },
      {
        Sid    = "AllowTagGetting"
        Effect = "Allow"
        Action = [
          "tag:GetResources"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "AllowInvokeLambda"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [aws_lambda_function.pexels_image_scraper.arn]
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_s3" {
  role       = aws_iam_role.rb_gha_s3_ecr.name
  policy_arn = aws_iam_policy.rb_gha.arn
}

resource "aws_iam_role" "pexels_image_scraper_lambda_exec" {
  name = "rb_pexels_image_scraper_lambda_exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "pexels_image_scraper_lambda_custom" {
  name        = "rbPexelsImageScraperLambdaCustomPolicy"
  description = "Custom policy for the Pexels Image Scraper Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ReadWrite"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = [
          "${aws_s3_bucket.rb_website_bucket.arn}/${var.s3_website_prefix}/data/*"
        ]
      },
      {
        Sid    = "AllowCloudFrontInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation"
        ]
        Resource = [
          aws_cloudfront_distribution.rb_website.arn
        ]
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.pexels_image_scraper_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "pexels_image_scraper_lambda_custom_attach" {
  role       = aws_iam_role.pexels_image_scraper_lambda_exec.name
  policy_arn = aws_iam_policy.pexels_image_scraper_lambda_custom.arn
}
