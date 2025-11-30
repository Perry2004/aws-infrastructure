data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

locals {
  alb_logs_bucket = var.alb_access_logs_bucket_name != "" ? var.alb_access_logs_bucket_name : "${var.app_short_name}-${var.env_name}-alb-logs"
}

resource "aws_s3_bucket" "cca_alb_logs" {
  count  = var.enable_alb_access_logs && var.alb_access_logs_bucket_name == "" ? 1 : 0
  bucket = local.alb_logs_bucket
  # bucket ACL will use default of 'private'


  tags = {
    Name        = "${var.app_short_name}-alb-logs"
    Environment = var.env_name
  }

  # encryption, versioning, lifecycle configuration managed outside of resource to match project style
}

resource "aws_s3_bucket_public_access_block" "cca_alb_logs" {
  count                   = var.enable_alb_access_logs && var.alb_access_logs_bucket_name == "" ? 1 : 0
  bucket                  = aws_s3_bucket.cca_alb_logs[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cca_alb_logs" {
  count  = var.enable_alb_access_logs && var.alb_access_logs_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.cca_alb_logs[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "cca_alb_logs" {
  count  = var.enable_alb_access_logs && var.alb_access_logs_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.cca_alb_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cca_alb_logs" {
  count  = var.enable_alb_access_logs && var.alb_access_logs_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.cca_alb_logs[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cca_alb_logs" {
  count  = var.enable_alb_access_logs && var.alb_access_logs_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.cca_alb_logs[0].id
  rule {
    id     = "alb-log-retention"
    status = "Enabled"
    filter {
      prefix = "AWSLogs/${data.aws_caller_identity.current.account_id}/elasticloadbalancing/"
    }
    expiration {
      days = 30
    }
  }
}
locals {
  log_prefix = var.alb_access_logs_bucket_prefix != "" ? "${var.alb_access_logs_bucket_prefix}/" : ""
}

resource "aws_s3_bucket_policy" "cca_alb_logs_policy" {
  count  = var.enable_alb_access_logs ? 1 : 0
  bucket = var.alb_access_logs_bucket_name != "" ? var.alb_access_logs_bucket_name : aws_s3_bucket.cca_alb_logs[0].id

  # LOGIC: If a prefix is set, add it with a trailing slash. If not, leave empty.

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowELBRootAccount"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action = "s3:PutObject"
        # UPDATED RESOURCE PATH BELOW
        Resource = "arn:aws:s3:::${local.alb_logs_bucket}/${local.log_prefix}AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      },
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:PutObject"
        # UPDATED RESOURCE PATH BELOW
        Resource = "arn:aws:s3:::${local.alb_logs_bucket}/${local.log_prefix}AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${local.alb_logs_bucket}"
      }
    ]
  })
}
