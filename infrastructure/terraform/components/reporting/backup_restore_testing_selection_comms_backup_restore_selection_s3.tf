resource "aws_backup_restore_testing_selection" "backup_restore_testing_selection_s3" {
  count = var.enable_s3_backup ? 1 : 0
  name                      = replace("${local.csi}_s3_backup_restore", "-", "_")
  restore_testing_plan_name = aws_backup_plan.s3_backup[0].name
  protected_resource_type   = "S3"
  iam_role_arn              = aws_iam_role.s3_backup[0].arn
  protected_resource_conditions {
    string_equals {
      key   = "aws:ResourceTag/Enable-Backup"
      value = true
    }
  }

  restore_metadata_overrides = {
    EncryptionType = "SSE_KMS"
    KmsKey         = aws_kms_alias.s3.arn
  }
}
