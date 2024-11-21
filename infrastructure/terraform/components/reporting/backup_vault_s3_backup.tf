resource "aws_backup_vault" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  name        = "${local.csi}-vault"
  kms_key_arn = aws_kms_key.backup[0].arn
}
