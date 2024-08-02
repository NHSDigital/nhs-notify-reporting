resource "aws_autoscaling_schedule" "scale_out" {
  count = var.enable_powerbi_gateway && var.scale_out_recurrence_schedule != null ? 1 : 0

  scheduled_action_name  = "${local.csi}-scale-out"
  desired_capacity       = var.desired_capacity
  min_size               = var.min_size
  max_size               = var.max_size
  autoscaling_group_name = aws_autoscaling_group.powerbi_gateway[0].name

  recurrence = coalesce(var.scale_in_recurrence_schedule, null)
}
