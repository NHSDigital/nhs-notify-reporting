resource "aws_cloudwatch_metric_alarm" "overdue_requests" {
  alarm_name                = "${local.csi}-overdue-requests"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = 1
  alarm_description         = "This metric monitors unexpected/overdue requests"

  metric_query {
    id          = "sum_overdue_requests_count"
    expression  = "SELECT SUM(OverdueRequestsCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
    return_data = "true"
    period      = 3600
  }
}
