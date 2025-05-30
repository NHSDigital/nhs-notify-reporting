resource "aws_cloudwatch_metric_alarm" "overdue_requests" {
  alarm_name          = "${local.csi}-overdue-requests"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_description   = "Requests that did not reach a terminal state within an expected time window"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "max_overdue_requests_count"
    expression  = "SELECT MAX(OverdueRequestsCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
    return_data = "true"
    period      = 3600
  }
}
