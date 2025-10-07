locals {
  alarm_period = 3600
}

resource "aws_cloudwatch_metric_alarm" "degraded_latency" {
  alarm_name          = "${local.csi}-degraded-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 2
  alarm_description   = "Triggers when multiple degraded-latency metrics are nonzero"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "count_degraded"
    expression  = <<-EOT
      SELECT COUNT_IF(DegradedLatenciesCount > 0)
      FROM "Notify/Watchdog"
      WHERE environment='${var.environment}'
      GROUP BY PERIOD(${local.alarm_period} SECONDS)
      FILL(0)
    EOT
    return_data = true
    period      = local.alarm_period
  }
}
