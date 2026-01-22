resource "aws_ssm_maintenance_window" "patch_window" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name                       = "${local.csi}-windows-patch-window"
  description                = "Windows Server 2022 Sunday Patch Window"
  schedule                   = "cron(0 3 ? * SUN *)" # Every Sunday at 3 AM
  duration                   = 4
  cutoff                     = 1
  allow_unassociated_targets = true
}
