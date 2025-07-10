resource "aws_iam_role_policy_attachment" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  role       = aws_iam_role.s3_backup[0].name
  policy_arn = aws_iam_policy.s3_backup[0].arn
}

resource "aws_iam_role_policy_attachment" "managed_backup" {
  count = var.enable_s3_backup ? 1 : 0

  role       = aws_iam_role.s3_backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
}

resource "aws_iam_role_policy_attachment" "managed_restore" {
  count = var.enable_s3_backup ? 1 : 0

  role       = aws_iam_role.s3_backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
}

resource "aws_iam_role_policy_attachment" "managed_backup_pol" {
  count = var.enable_s3_backup ? 1 : 0

  role       = aws_iam_role.s3_backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "managed_backup_restore" {
  count = var.enable_s3_backup ? 1 : 0

  role       = aws_iam_role.s3_backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForRestores"
}
