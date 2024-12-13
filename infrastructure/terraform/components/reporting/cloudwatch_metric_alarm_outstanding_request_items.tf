resource "aws_cloudwatch_metric_alarm" "outstanding_request_items" {
  alarm_name                = "${local.csi}-outstanding-request-items"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = 1
  alarm_description         = "This metric monitors unexpected/overdue outstanding request items"

  metric_query {
    id          = "sum_outstanding_request_items_count"
    expression  = "SELECT SUM(OutstandingRequestItemsCount) FROM \"Notify/Watchdog\""
    return_data = "true"
    period      = 10800
  }
}
