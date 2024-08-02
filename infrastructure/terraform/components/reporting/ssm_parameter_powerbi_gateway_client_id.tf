resource "aws_ssm_parameter" "powerbi_gateway_client_id" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name        = "/${local.csi}/powerbi-gateway-client-id"
  description = "The Client (Application) ID for the Service Principal"
  type        = "SecureString"
  value       = "CLIENT_ID_PLACEHOLDER"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
