resource "aws_cloudwatch_metric_alarm" "athena_workgroup_processed_bytes_ingestion" {
  alarm_name          = "${local.csi}-athena-workgroup-processed-bytes-ingestion"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ProcessedBytes"
  namespace           = "AWS/Athena"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000000000
  alarm_description   = "Alarm for spikes in Athena Workgroup ProcessedBytes (ingestion)."
  treat_missing_data  = "notBreaching"
  dimensions = {
    WorkGroup = aws_athena_workgroup.ingestion.name
  }
}
