resource "aws_cloudwatch_metric_alarm" "overdue_request_items" {
  alarm_name                = "${local.csi}-overdue-request-items"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = 1
  alarm_description         = "This metric monitors unexpected/overdue request items"

  metric_query {
    id          = "sum_overdue_request_items_count"
    expression  = "SELECT SUM(OverdueRequestItemsCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
    return_data = "true"
    period      = 3600
  }
}
