resource "aws_backup_plan" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  name = "${local.csi}-backup-plan"

  rule {
    rule_name                = "ContinuousBackupRule"
    target_vault_name        = aws_backup_vault.s3_backup[0].name
    enable_continuous_backup = true

    lifecycle {
      delete_after = var.continuous_s3backup_retention_days
    }
  }

  rule {
    rule_name                = "PeriodicBackupRule"
    target_vault_name        = aws_backup_vault.s3_backup[0].name
    schedule                 = var.periodic_s3backup_schedule
    enable_continuous_backup = false

    copy_action {
      destination_vault_arn = var.destination_backup_vault_arn
      lifecycle {
        delete_after = var.periodic_s3backup_retention_days
      }
    }

    lifecycle {
      delete_after = var.periodic_s3backup_retention_days
    }
  }
}
