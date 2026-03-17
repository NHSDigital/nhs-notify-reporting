resource "aws_ssm_parameter" "powerbi_gateway_recovery_key" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name        = "/${local.csi}/powerbi-gateway-recovery-key"
  description = "The Recovery Key for the On-Premises Gateway - Updated manually with the actual key value after deployment"
  type        = "SecureString"
  value       = "RECOVERY_KEY_PLACEHOLDER"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
