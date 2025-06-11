resource "aws_cloudwatch_metric_alarm" "degraded_latency" {
  alarm_name          = "${local.csi}-degraded-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_description   = "Today's latencies are significantly higher than historic trends"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "max_degraded_latency_count"
    expression  = "SELECT MAX(DegradedLatenciesCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
    return_data = "true"
    period      = 3600
  }
}
