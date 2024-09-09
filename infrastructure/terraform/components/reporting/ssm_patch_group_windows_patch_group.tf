resource "aws_ssm_patch_group" "windows_patch_group" {
  count = var.enable_powerbi_gateway ? 1 : 0

  baseline_id = aws_ssm_patch_baseline.windows_patch_baseline[0].id
  patch_group = "${local.csi}-windows-group"
}
