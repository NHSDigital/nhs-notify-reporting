resource "aws_cloudwatch_metric_alarm" "powerbi_gateway_group_health" {
  count = var.enable_powerbi_gateway ? 1 : 0

  alarm_name          = "${local.csi}-powerbi-gateway-group-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = 300
  statistic           = "Average"
  threshold           = var.desired_capacity
  alarm_description   = "Alarm when the Power BI gateway Auto Scaling group has fewer in-service instances than desired"
  treat_missing_data  = "breaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.powerbi_gateway[0].name
  }
}
