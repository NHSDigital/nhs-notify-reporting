resource "aws_cloudwatch_metric_alarm" "powerbi_gateway_standalone_status_check_failed" {
  for_each = var.enable_powerbi_gateway ? {
    for idx, instance in aws_instance.powerbi_gateway_standalone :
    idx => {
      id   = instance.id
      name = format("%s-powerbi-gateway-standalone-%02d-status-check-failed", local.csi, idx + 1)
    }
  } : {}

  alarm_name          = each.value.name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "Instance or system status check failed for a standalone Power BI gateway host"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = each.value.id
  }
}
