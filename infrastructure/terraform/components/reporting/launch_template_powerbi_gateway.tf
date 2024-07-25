resource "aws_launch_template" "powerbi_gateway" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name                                 = local.csi
  description                          = "Template for the Power BI On-Premises Gateway"
  update_default_version               = true
  image_id                             = var.windows_ami_id
  instance_type                        = var.instance_type
  user_data                            = data.cloudinit_config.powerbi_gateway.rendered
  instance_initiated_shutdown_behavior = var.enable_spot ? "terminate" : "stop"
  ebs_optimized                        = true

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ebs[0].arn
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.powerbi_gateway[0].name
  }

  dynamic "instance_market_options" {
    for_each = var.enable_spot ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price          = var.spot_max_price
        spot_instance_type = "one-time"
      }
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    delete_on_termination       = true
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.powerbi_gateway[0].id
    ]
    subnet_id = element(module.powerbi_gateway_vpc.private_subnets, count.index)
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 5
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.deployment_default_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.deployment_default_tags
  }
}
