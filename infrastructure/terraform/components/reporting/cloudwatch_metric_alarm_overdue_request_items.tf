resource "aws_cloudwatch_metric_alarm" "overdue_request_items" {
  alarm_name          = "${local.csi}-overdue-request-items"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_description   = "Request items that did not reach a terminal state within an expected time window"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "max_overdue_request_items_count"
    expression  = "SELECT MAX(OverdueRequestItemsCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
    return_data = "true"
    period      = 3600
  }
}
