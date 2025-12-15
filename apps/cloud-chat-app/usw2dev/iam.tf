resource "aws_iam_role" "github_actions_role" {
  name = "${var.app_short_name}-gha-role"
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
            "token.actions.githubusercontent.com:sub" = "repo:${var.app_github_repo}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cca_gha_policy" {
  name        = "${upper(var.app_short_name)}-GHA-Policy"
  description = "Policy for GitHub Actions to access ECR repositories for ${var.app_short_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTagGetting"
        Effect = "Allow"
        Action = [
          "tag:GetResources"
        ]
        Resource = ["*"]
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
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage"
        ]
        Resource = [for repo in aws_ecr_repository.app_repositories : repo.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.cca_gha_policy.arn
}

# role used by ECS to launch and manage tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_short_name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.app_short_name}-ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_task_policy" {
  name_prefix = "${var.app_short_name}-ecs-task-policy"
  description = "Runtime policy for ECS tasks in ${var.app_short_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.app_short_name}/*"
      },
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name_prefix = "${var.app_short_name}-ecs-exec-policy"
  description = "Policy to allow ECS Exec functionality for ${var.app_short_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.app_short_name}/*"
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

# role used by ECS tasks (runtime role)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_short_name}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.app_short_name}-ecs-task-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_exec_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# IAM user dedicated to Auth0 SES integration
resource "aws_iam_user" "auth0_ses" {
  name = "${var.app_short_name}-auth0-ses"

  tags = {
    Name = "${var.app_short_name}-auth0-ses"
  }
}

resource "aws_iam_user_policy" "auth0_ses_send_policy" {
  name = "${upper(var.app_short_name)}-Auth0-SES-Send"
  user = aws_iam_user.auth0_ses.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSendEmail"
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = [
          aws_ses_domain_identity.chat_domain.arn,
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

resource "aws_iam_access_key" "auth0_ses" {
  user = aws_iam_user.auth0_ses.name
}

