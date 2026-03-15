resource "aws_iam_role" "gp_news_gha_ecr" {
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
            "token.actions.githubusercontent.com:sub" = "repo:Perry2004/GP-News:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "gp_news_gha" {
  name        = "ReadWrite-GP-News-ECR"
  description = "Allow the GP-News GitHub Actions to update the ECR image for the lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
  role       = aws_iam_role.gp_news_gha_ecr.name
  policy_arn = aws_iam_policy.gp_news_gha.arn
}

resource "aws_iam_role" "gp_news_lambda_exec" {
  name = "gp_news_lambda_exec"

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

resource "aws_iam_policy" "gp_news_lambda_custom" {
  name        = "GPNewsLambdaCustomPolicy"
  description = "Custom policy for the GP-News Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowSendEmail"
      Effect = "Allow"
      Action = [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      Resource = [
        aws_ses_domain_identity.gp_news_domain,
        aws_ses_email_identity.do_not_reply.arn
      ]
      Condition = {
        StringEquals = {
          "ses:FromAddress" = aws_ses_email_identity.do_not_reply.email
        }
      }
      },
      {
        Sid    = "AllowSendQuotaRead"
        Effect = "Allow"
        Action = [
          "ses:GetSendQuota",
          "ses:GetSendStatistics"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.gp_news_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "gp_news_lambda_custom_attach" {
  role       = aws_iam_role.gp_news_lambda_exec.name
  policy_arn = aws_iam_policy.gp_news_lambda_custom.arn
}
