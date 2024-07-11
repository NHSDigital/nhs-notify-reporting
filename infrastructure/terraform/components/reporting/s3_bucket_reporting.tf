resource "aws_s3_bucket" "reporting" {
  bucket        = "${local.csi_global}-daily-report"
  force_destroy = "true"
}

resource "aws_s3_bucket_ownership_controls" "reporting" {
  bucket = aws_s3_bucket.reporting.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reporting" {
  bucket = aws_s3_bucket.reporting.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.s3.id
    }
  }
}

resource "aws_s3_bucket_versioning" "reporting" {
  bucket = aws_s3_bucket.reporting.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "reporting" {
  depends_on = [
    aws_s3_bucket_policy.reporting
  ]

  bucket = aws_s3_bucket.reporting.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "reporting" {
  bucket = aws_s3_bucket.reporting.id

  target_bucket = aws_s3_bucket.access_logs.bucket
  target_prefix = "nhs-notify/${aws_s3_bucket.reporting.bucket}/"
}
