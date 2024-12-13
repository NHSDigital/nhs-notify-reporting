resource "aws_cloudwatch_metric_alarm" "outstanding_requests" {
  alarm_name                = "${local.csi}-outstanding-requests"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = 1
  alarm_description         = "This metric monitors unexpected outstanding requests"

  metric_query {
    id          = "SumOutstandingRequestCount"
    expression  = "SELECT SUM(OutstandingRequestCount) FROM \"Notify/Watchdog\""
    return_data = "true"
    period      = 10800
  }
}
