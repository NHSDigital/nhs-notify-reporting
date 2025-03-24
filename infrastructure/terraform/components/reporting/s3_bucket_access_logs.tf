#tfsec:ignore:aws-s3-enable-bucket-logging Don't log access logs logs
resource "aws_s3_bucket" "access_logs" {
  bucket        = "${local.csi_global}-bucket-logs"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  policy = data.aws_iam_policy_document.access_logs_bucket_policy.json
}

data "aws_iam_policy_document" "access_logs_bucket_policy" {
  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.access_logs.arn,
      "${aws_s3_bucket.access_logs.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        false
      ]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.access_logs.arn}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SourceAccount"
      values = [
        local.parameter_bundle.account_ids[local.parameter_bundle.account_name]
      ]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  depends_on = [
    aws_s3_bucket.access_logs,
    aws_s3_bucket_policy.access_logs
  ]
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# From Support ticket: Where the client is looking to enable bucket keys on the target S3 bucket, the recommended approach would be:
# 1. Remove the KMS key from the Athena workgroup's encryption configuration: Since the bucket keys will be handling the encryption, you don't need the additional layer of encryption from the workgroup-level KMS key. Removing it will simplify the configuration.
# 2. Rely solely on the bucket keys for encryption: With the bucket keys enabled on the S3 bucket, Athena will automatically use that for encrypting and decrypting the query results. This will reduce the no of API calls.
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket                = aws_s3_bucket.access_logs.id
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


