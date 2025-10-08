resource "aws_cloudwatch_metric_alarm" "degraded_latency" {
  alarm_name          = "${local.csi}-degraded-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 2
  alarm_description   = "Triggers when multiple clients/campaigns experience degraded latencies simultaneously"
  treat_missing_data  = "notBreaching"

  metric_query {
    id     = "degraded_latencies_count_max"
    expression = <<-EOT
      SELECT MAX(DegradedLatenciesCount)
      FROM "Notify/Watchdog"
      WHERE environment='${var.environment}'
      GROUP BY environment, clientid, campaignid
    EOT
    return_data = false
    period = 3600
  }

  metric_query {
    id          = "degraded_client_campaign_count"
    # Not particularly intuitive but needed to compare equivalent types TS[]
    expression = "SUM( IF( degraded_latencies_count_max > (degraded_latencies_count_max * 0), 1, 0 ) )"
    return_data = true
  }
}
