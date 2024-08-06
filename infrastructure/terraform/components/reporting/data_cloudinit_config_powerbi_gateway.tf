data "cloudinit_config" "powerbi_gateway" {
  count = var.enable_powerbi_gateway ? 1 : 0

  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = local.powerbi_gateway_script
  }
}

locals {
  powerbi_gateway_script = templatefile("${path.module}/templates/cloudinit_config.tmpl", {
    odbc_dsn_name       = "${local.csi}-dsn"
    odbc_description    = "AWS Simba Athena ODBC Connection for ${local.csi}"
    region              = var.region
    catalog             = "AWSDataCatalog"
    database            = aws_glue_catalog_database.reporting.name
    workgroup           = aws_athena_workgroup.user.name
    authentication_type = "Instance Profile"
  })
}