resource "aws_ssm_patch_baseline" "windows_patch_baseline" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name             = "${local.csi}-windows-patch-baseline"
  description      = "Windows Server 2022 Patch Baseline"
  operating_system = "WINDOWS"
  approval_rule {
    patch_filter {
      key    = "PRODUCT"
      values = ["WindowsServer2022"]
    }
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["SecurityUpdates", "CriticalUpdates"]
    }
    patch_filter {
      key = "MSRC_SEVERITY"
      values = [
        "Critical",
        "Important",
      ]
    }
  }
}
