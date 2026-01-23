resource "aws_autoscaling_group" "powerbi_gateway" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name = local.csi

  launch_template {
    id      = aws_launch_template.powerbi_gateway_asg[0].id
    version = "$Latest"
  }

  vpc_zone_identifier = module.powerbi_gateway_vpc[0].private_subnets
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size

  tag {
    key                 = "Name"
    value               = "${local.csi}-powerbi-gateway-instance"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  wait_for_capacity_timeout = "0"
}
