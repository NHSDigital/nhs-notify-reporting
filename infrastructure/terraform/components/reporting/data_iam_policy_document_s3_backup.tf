data "aws_iam_policy_document" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketVersioning"
    ]
    resources = [
      aws_s3_bucket.data.arn,
      "${aws_s3_bucket.data.arn}/*",
      aws_s3_bucket.results.arn,
      "${aws_s3_bucket.results.arn}/*"
    ]
  }

  statement {
    actions = [
      "backup:StartBackupJob",
      "backup:ListRecoveryPointsByBackupVault",
      "backup:StartRestoreJob"
    ]
    resources = ["*"]
  }
}
