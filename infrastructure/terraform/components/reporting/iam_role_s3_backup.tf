resource "aws_iam_role" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  name                = "${local.csi}-AWSBackupServiceRole"
  description         = "AWS S3 Backup Role"
  assume_role_policy  = data.aws_iam_policy_document.s3_backup_assume_role[0].json
}
