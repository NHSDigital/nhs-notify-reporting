resource "aws_s3_bucket" "results" {
  bucket        = "${local.csi_global}-results"
  force_destroy = "true"
}

resource "aws_s3_bucket_ownership_controls" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.s3.id
    }
  bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "results" {
  bucket = aws_s3_bucket.results.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "results" {
  depends_on = [
    aws_s3_bucket_policy.results
  ]

  bucket = aws_s3_bucket.results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "results" {
  bucket = aws_s3_bucket.results.id

  target_bucket = aws_s3_bucket.access_logs.bucket
  target_prefix = "nhs-notify/${aws_s3_bucket.results.bucket}/"
}

resource "aws_s3_bucket_lifecycle_configuration" "results" {
  bucket                = aws_s3_bucket.results.id
  expected_bucket_owner = local.this_account

  rule {
    id     = "default_current_version"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = "90"
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = "180"
      storage_class = "GLACIER"
    }

    expiration {
      days = "365"
    }
  }

  rule {
    id     = "default_non_current_version"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_transition {
      noncurrent_days = "90"
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = "180"
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = "365"
    }
  }
}