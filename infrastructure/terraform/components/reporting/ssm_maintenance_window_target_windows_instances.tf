resource "aws_ssm_maintenance_window_target" "windows_instances_sunday" {
  count = var.enable_powerbi_gateway && var.powerbi_gateway_instance_count >= 1 ? 1 : 0

  description   = "Windows Server 2022 Sunday Maintenance Window Target "
  window_id     = aws_ssm_maintenance_window.patch_window_sunday[0].id
  resource_type = "INSTANCE"
  name          = "${local.csi}-maintenance-window-target-sun"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.powerbi_gateway_standalone[0].id]
  }
}

resource "aws_ssm_maintenance_window_target" "windows_instances_wednesday" {
  count = var.enable_powerbi_gateway && var.powerbi_gateway_instance_count >= 2 ? 1 : 0

  description   = "Windows Server 2022 Wednesday Maintenance Window Target"
  window_id     = aws_ssm_maintenance_window.patch_window_wednesday[0].id
  resource_type = "INSTANCE"
  name          = "${local.csi}-maintenance-window-target-wed"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.powerbi_gateway_standalone[1].id]
  }
}
