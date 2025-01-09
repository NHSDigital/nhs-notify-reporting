resource "aws_cloudwatch_metric_alarm" "overdue_request_item_plans" {
  alarm_name                = "${local.csi}-overdue-request-item-plans"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = 1
  alarm_description         = "This metric monitors unexpected/overdue request item plans"

  dimensions = {
    environment = local.csi
  }

  metric_query {
    id          = "sum_overdue_request_item_plans_count"
    expression  = "SELECT SUM(OverdueRequestItemPlansCount) FROM \"Notify/Watchdog\""
    return_data = "true"
    period      = 3600
  }
}
