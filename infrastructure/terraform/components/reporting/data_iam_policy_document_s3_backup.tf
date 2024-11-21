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
    ]
  }

  statement {
    actions = [
      "events:DeleteRule",
      "events:DescribeRule",
      "events:DisableRule",
      "events:EnableRule",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets"
    ]
    resources = [
      "arn:aws:events:${var.region}:${local.this_account}:rule/AwsBackupManagedRule-*"
    ]
  }

  statement {
    actions = [
      "backup:ListRecoveryPointsByBackupVault",
      "backup:StartBackupJob",
    ]
    resources = [
      aws_backup_vault.s3_backup[0].arn
    ]
  }

  statement {
    actions = [
      "backup:StartRestoreJob"
    ]
    resources = [
      "arn:aws:backup:${var.region}:${local.this_account}:recovery-point:${var.project}-${local.this_account}-${var.region}-${var.environment}-*"
    ]
  }

  statement {
    actions = [
      "cloudwatch:GetMetricData", # List action, cannot be scoped
      "events:ListRules"          # List action, cannot be scoped
    ]
    resources = ["*"]
  }
}
