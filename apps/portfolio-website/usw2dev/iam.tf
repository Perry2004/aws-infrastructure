# allow website GHA to push build artifacts to S3
resource "aws_iam_role" "pwp_gha_s3" {
  name = "PWP-GHA-S3-ReadWrite"

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
  name        = "ReadWrite-PortfolioWebsite-S3"
  description = "Allow the portfolio website GitHub Actions to update the latest build artifacts in S3"

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
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_s3" {
  role       = aws_iam_role.pwp_gha_s3.name
  policy_arn = aws_iam_policy.pwp_gha.arn
}
