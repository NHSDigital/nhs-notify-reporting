resource "aws_cloudwatch_metric_alarm" "outstanding_requests" {
  alarm_name                = "${local.csi}-outstanding-requests"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = 1
  alarm_description         = "This metric monitors unexpected/overdue outstanding requests"

  metric_query {
    id          = "sum_outstanding_requests_count"
    expression  = "SELECT SUM(OutstandingRequestsCount) FROM \"Notify/Watchdog\""
    return_data = "true"
    period      = 10800
  }
}
