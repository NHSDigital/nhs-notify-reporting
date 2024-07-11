resource "aws_s3_bucket_policy" "daily_report" {
  bucket = aws_s3_bucket.daily_report.id
  policy = data.aws_iam_policy_document.daily_report.json
}

data "aws_iam_policy_document" "daily_report" {
  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.daily_report.arn,
      "${aws_s3_bucket.daily_report.arn}/*",
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
}
