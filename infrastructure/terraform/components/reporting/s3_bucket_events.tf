resource "aws_s3_bucket" "events" {
  bucket        = "${local.csi_global}-events"
  force_destroy = "false"
}

resource "aws_s3_bucket_ownership_controls" "events" {
  bucket = aws_s3_bucket.events.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "events" {
  bucket = aws_s3_bucket.events.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.s3.id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "events" {
  bucket = aws_s3_bucket.events.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "events" {
  depends_on = [
    aws_s3_bucket_policy.events
  ]

  bucket = aws_s3_bucket.events.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "events" {
  bucket = aws_s3_bucket.events.id

  target_bucket = aws_s3_bucket.access_logs.bucket
  target_prefix = "nhs-notify/${aws_s3_bucket.events.bucket}/"
}

resource "aws_s3_bucket_lifecycle_configuration" "events" {
  bucket                = aws_s3_bucket.events.id
  expected_bucket_owner = local.this_account

  rule {
    id     = "events"
    status = "Enabled"

    filter {
    }

    expiration {
      days = var.event_staging_retention_config.current_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.event_staging_retention_config.non_current_days
    }
  }
}
