resource "aws_cloudwatch_metric_alarm" "athena_workgroup_processed_bytes_setup" {
  alarm_name          = "${local.csi}-athena-workgroup-processed-bytes-setup"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  alarm_description   = "Alarm for anomalous spikes in Athena Workgroup ProcessedBytes (setup)."
  treat_missing_data  = "notBreaching"
  threshold_metric_id = "ad1"

  metric_query {
    id          = "m1"
    metric {
      metric_name = "ProcessedBytes"
      namespace   = "AWS/Athena"
      period      = 300
      stat        = "Sum"
      dimensions = {
        WorkGroup = aws_athena_workgroup.setup.name
      }
    }
    return_data = true
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 4)"
    label       = "Anomaly Detection Band"
    return_data = true
  }
}
