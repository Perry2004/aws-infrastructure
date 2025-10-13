resource "aws_s3_bucket" "portfolio_website_bucket" {
  bucket = "perryz-portfolio-website-${var.env_name}"
}

resource "aws_s3_bucket_ownership_controls" "portfolio_website_bucket" {
  bucket = aws_s3_bucket.portfolio_website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# block all public access
resource "aws_s3_bucket_public_access_block" "portfolio_website_bucket" {
  bucket = aws_s3_bucket.portfolio_website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "portfolio_website_bucket" {
  bucket = aws_s3_bucket.portfolio_website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "portfolio_website_bucket" {
  bucket = aws_s3_bucket.portfolio_website_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# keep 3 versions for 90 days
resource "aws_s3_bucket_lifecycle_configuration" "portfolio_website_bucket" {
  bucket = aws_s3_bucket.portfolio_website_bucket.id

  rule {
    id     = "versioning_rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days           = var.data_retention_days
      newer_noncurrent_versions = var.num_versions_to_keep
    }
  }
}

resource "aws_s3_bucket_policy" "portfolio_website_oac_policy" {
  bucket = aws_s3_bucket.portfolio_website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.portfolio_website_bucket.arn}/${var.s3_website_prefix}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.portfolio_website.arn
          }
        }
      }
    ]
  })
}
