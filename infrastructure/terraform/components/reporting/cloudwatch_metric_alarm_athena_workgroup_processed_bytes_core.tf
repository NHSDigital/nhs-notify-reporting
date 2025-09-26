resource "aws_cloudwatch_metric_alarm" "athena_workgroup_processed_bytes_core" {
  alarm_name          = "${local.csi}-athena-workgroup-processed-bytes-core"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ProcessedBytes"
  namespace           = "AWS/Athena"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000000000
  alarm_description   = "Alarm for spikes in Athena Workgroup ProcessedBytes (core)."
  treat_missing_data  = "notBreaching"

  dimensions = {
    WorkGroup = aws_athena_workgroup.core.name
  }
}