resource "aws_ssm_parameter" "powerbi_gateway_tenant_id" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name        = "/${local.csi}/powerbi-gateway-tenant-id"
  description = "The Tenant ID for the Service Principal"
  type        = "SecureString"
  value       = "TENANT_ID_PLACEHOLDER"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
