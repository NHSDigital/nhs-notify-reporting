data "cloudinit_config" "powerbi_gateway" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/cloudinit_config.ps1")
  }
}
