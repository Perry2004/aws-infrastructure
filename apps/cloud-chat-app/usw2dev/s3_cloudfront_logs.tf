# S3 bucket to store CloudFront access logs
locals {
  cloudfront_logs_bucket = var.cloudfront_access_logs_bucket_name != "" ? var.cloudfront_access_logs_bucket_name : "${var.app_short_name}-${var.env_name}-cloudfront-logs"
}

resource "aws_s3_bucket" "cca_cloudfront_logs" {
  count  = var.enable_cloudfront_access_logs && var.cloudfront_access_logs_bucket_name == "" ? 1 : 0
  bucket = local.cloudfront_logs_bucket
  # bucket ACL will use default of 'private'

  tags = {
    Name        = "${var.app_short_name}-cloudfront-logs"
    Environment = var.env_name
  }
}

# make the bucket private
resource "aws_s3_bucket_public_access_block" "cca_cloudfront_logs" {
  count                   = var.enable_cloudfront_access_logs && var.cloudfront_access_logs_bucket_name == "" ? 1 : 0
  bucket                  = aws_s3_bucket.cca_cloudfront_logs[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cca_cloudfront_logs" {
  count  = var.enable_cloudfront_access_logs && var.cloudfront_access_logs_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.cca_cloudfront_logs[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "cca_cloudfront_logs" {
  count  = var.enable_cloudfront_access_logs && var.cloudfront_access_logs_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.cca_cloudfront_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cca_cloudfront_logs" {
  count  = var.enable_cloudfront_access_logs && var.cloudfront_access_logs_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.cca_cloudfront_logs[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cca_cloudfront_logs" {
  count  = var.enable_cloudfront_access_logs && var.cloudfront_access_logs_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.cca_cloudfront_logs[0].id
  rule {
    id     = "cloudfront-log-retention"
    status = "Enabled"
    filter {
      prefix = var.cloudfront_access_logs_bucket_prefix != "" ? "${var.cloudfront_access_logs_bucket_prefix}/" : ""
    }
    expiration {
      days = 30
    }
  }
}

locals {
  cloudfront_log_prefix = var.cloudfront_access_logs_bucket_prefix != "" ? "${var.cloudfront_access_logs_bucket_prefix}/" : ""
}

resource "aws_s3_bucket_policy" "cca_cloudfront_logs_policy" {
  count  = var.enable_cloudfront_access_logs ? 1 : 0
  bucket = var.cloudfront_access_logs_bucket_name != "" ? var.cloudfront_access_logs_bucket_name : aws_s3_bucket.cca_cloudfront_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${local.cloudfront_logs_bucket}/${local.cloudfront_log_prefix}*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "aws:SourceArn"     = "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryWrite1"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${local.cloudfront_logs_bucket}/${local.cloudfront_log_prefix}*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:delivery-source:cca-cloudfront-logs"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${local.cloudfront_logs_bucket}"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "aws:SourceArn"     = "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}
