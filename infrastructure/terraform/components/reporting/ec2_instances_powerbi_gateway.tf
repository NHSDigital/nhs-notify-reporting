resource "aws_instance" "powerbi_gateway_standalone" {
  count = var.enable_powerbi_gateway ? var.powerbi_gateway_instance_count : 0

  associate_public_ip_address = false
  launch_template {
    id      = aws_launch_template.powerbi_gateway_standalone[0].id
    version = "$Latest"
  }

  tags = {
    Name = format("%s-powerbi-gateway-standalone-%02d", local.csi, count.index + 1)
  }
}
