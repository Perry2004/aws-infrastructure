# allow website GHA to push build artifacts to S3
resource "aws_iam_role" "pwp_gha_s3_ecr" {
  name = "PWP-GHA-S3-ECR-ReadWrite"

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
            "token.actions.githubusercontent.com:sub" = "repo:Perry2004/perry2004.github.io:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "pwp_gha" {
  name        = "ReadWrite-PortfolioWebsite-S3-ECR"
  description = "Allow the portfolio website GitHub Actions to update the latest build artifacts in S3 and ECR"

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
          aws_s3_bucket.portfolio_website_bucket.arn
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
          "${aws_s3_bucket.portfolio_website_bucket.arn}/*"
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
          aws_cloudfront_distribution.portfolio_website.arn
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
        Sid    = "AllowECRGetToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = ["*"]
      },
      {
        Sid    = "AllowECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = [aws_ecr_repository.lambda_container_repo.arn]
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_s3" {
  role       = aws_iam_role.pwp_gha_s3_ecr.name
  policy_arn = aws_iam_policy.pwp_gha.arn
}

resource "aws_iam_role" "pexels_image_scraper_lambda_exec" {
  name = "pexels_image_scraper_lambda_exec"

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
  name        = "PexelsImageScraperLambdaCustomPolicy"
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
          "${aws_s3_bucket.portfolio_website_bucket.arn}/website/data/*"
        ]
      }
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
