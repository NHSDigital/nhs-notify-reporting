resource "aws_backup_vault_lock_configuration" "s3_backup" {
  count = var.enable_s3_backup && var.enable_vault_lock_configuration ? 1 : 0

  backup_vault_name = aws_backup_vault.s3_backup[0].name
}
