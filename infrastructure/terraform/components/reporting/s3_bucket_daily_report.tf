resource "aws_s3_bucket" "daily_report" {
  bucket        = "${local.csi_global}-daily-report"
  force_destroy = "true"
}

resource "aws_s3_bucket_ownership_controls" "daily_report" {
  bucket = aws_s3_bucket.daily_report.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "daily_report" {
  bucket = aws_s3_bucket.daily_report.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.s3.id
    }
  }
}

resource "aws_s3_bucket_versioning" "daily_report" {
  bucket = aws_s3_bucket.daily_report.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "daily_report" {
  depends_on = [
    aws_s3_bucket_policy.daily_report
  ]

  bucket = aws_s3_bucket.daily_report.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "daily_report" {
  bucket = aws_s3_bucket.daily_report.id

  target_bucket = aws_s3_bucket.access_logs.bucket
  target_prefix = "nhs-notify/${aws_s3_bucket.daily_report.bucket}/"
}
