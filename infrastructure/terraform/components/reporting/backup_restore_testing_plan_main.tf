resource "aws_backup_restore_testing_plan" "main" {
  count = var.enable_s3_backup ? 1 : 0
  name = replace("${local.csi}_restore_testing_plan", "-", "_")

  recovery_point_selection {
    algorithm            = "LATEST_WITHIN_WINDOW"
    include_vaults       = ["*"]
    recovery_point_types = ["SNAPSHOT"]
  }

  schedule_expression = "cron(0 4 ? * wed *)"
}