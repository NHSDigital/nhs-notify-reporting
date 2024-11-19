data "aws_iam_policy_document" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetBucketVersioning",
      "s3:GetBucketTagging",
      "s3:GetBucketLocation",
      "s3:GetBucketNotification",
      "s3:PutBucketNotification"
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
      "backup:StartRestoreJob",
      "events:ListRules",
      "events:PutRule",
      "events:ListTargetsByRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "cloudwatch:GetMetricData"
    ]
    resources = ["*"]
  }
}
