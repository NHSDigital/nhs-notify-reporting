resource "aws_ssm_parameter" "powerbi_gateway_client_secret" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name        = "/${local.csi}/powerbi-gateway-client-secret"
  description = "The Client Secret for the Service Principal"
  type        = "SecureString"
  value       = "CLIENT_SECRET_PLACEHOLDER"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
