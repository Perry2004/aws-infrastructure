resource "aws_s3_bucket" "gp_news_bucket" {
  bucket = "gp-news-${var.env_name}"
}

resource "aws_s3_bucket_ownership_controls" "gp_news_bucket" {
  bucket = aws_s3_bucket.gp_news_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# block all public access
resource "aws_s3_bucket_public_access_block" "gp_news_bucket" {
  bucket = aws_s3_bucket.gp_news_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "gp_news_bucket" {
  bucket = aws_s3_bucket.gp_news_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gp_news_bucket" {
  bucket = aws_s3_bucket.gp_news_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# keep 3 versions for 90 days
resource "aws_s3_bucket_lifecycle_configuration" "gp_news_bucket" {
  bucket = aws_s3_bucket.gp_news_bucket.id

  rule {
    id     = "versioning_rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days           = var.data_retention_days
      newer_noncurrent_versions = var.num_versions_to_keep
    }
  }
}
