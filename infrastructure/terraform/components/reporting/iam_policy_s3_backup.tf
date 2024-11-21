resource "aws_iam_policy" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  name        = "${local.csi}-AWSBackupS3AccessPolicy"
  description = "IAM policy for AWS Backup to access Reporting S3 buckets"
  policy      = data.aws_iam_policy_document.s3_backup[0].json
}
