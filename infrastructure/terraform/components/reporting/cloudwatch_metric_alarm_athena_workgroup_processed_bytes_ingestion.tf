resource "aws_cloudwatch_metric_alarm" "athena_workgroup_processed_bytes_ingestion" {
  alarm_name          = "${local.csi}-athena-workgroup-processed-bytes-ingestion"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  alarm_description   = "Alarm for anomalous spikes in Athena Workgroup ProcessedBytes (ingestion)."
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
        WorkGroup = aws_athena_workgroup.ingestion.name
      }
    }
    return_data = false
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "Anomaly Detection Band"
    return_data = true
  }
}
