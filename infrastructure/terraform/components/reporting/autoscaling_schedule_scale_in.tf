resource "aws_autoscaling_schedule" "scale_in" {
  count = var.enable_powerbi_gateway ? 1 : 0

  scheduled_action_name  = "${local.csi}-scale-in"
  desired_capacity       = 0
  min_size               = 0
  max_size               = -1
  recurrence             = "0 17 * * 1-5" # At 05:00 PM, Monday through Friday
  autoscaling_group_name = aws_autoscaling_group.powerbi_gateway[0].name
}
