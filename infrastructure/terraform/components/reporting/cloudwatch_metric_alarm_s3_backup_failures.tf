resource "aws_cloudwatch_metric_alarm" "s3_backup_failures" {
  alarm_name                = "${local.csi}-s3-backup-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "NumberOfBackupJobsFailed"
  namespace                 = "AWS/Backup"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "This metric monitors AWS Backup Failures"
  insufficient_data_actions = []

  dimensions = {
    BackupVaultName = aws_backup_vault.s3_backup.name
  }
}