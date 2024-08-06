data "cloudinit_config" "powerbi_gateway" {
  count = var.enable_powerbi_gateway ? 1 : 0

  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = local.powerbi_gateway_script
  }
}
