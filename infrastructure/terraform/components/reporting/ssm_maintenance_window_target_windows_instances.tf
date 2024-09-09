resource "aws_ssm_maintenance_window_target" "windows_instances" {
  count = var.enable_powerbi_gateway ? 1 : 0

  description   = "Windows Server 2022 Maintenance Window Target"
  window_id     = aws_ssm_maintenance_window.patch_window[0].id
  resource_type = "INSTANCE"
  name          = "${local.csi}-maintenance-window-target"

  targets {
    key    = "tag:Patch Group"
    values = ["${local.csi}-windows-group"]
  }
}
