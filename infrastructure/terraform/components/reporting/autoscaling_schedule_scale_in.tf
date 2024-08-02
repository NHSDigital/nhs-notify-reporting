resource "aws_autoscaling_schedule" "scale_in" {
  count = var.enable_powerbi_gateway && var.scale_in_recurrence_schedule != null ? 1 : 0

  scheduled_action_name  = "${local.csi}-scale-in"
  desired_capacity       = 0
  min_size               = 0
  max_size               = -1
  autoscaling_group_name = aws_autoscaling_group.powerbi_gateway[0].name

  recurrence = coalesce(var.scale_in_recurrence_schedule, null)
}
