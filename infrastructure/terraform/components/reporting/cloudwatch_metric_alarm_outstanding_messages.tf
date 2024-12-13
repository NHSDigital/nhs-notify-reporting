resource "aws_cloudwatch_metric_alarm" "outstanding_messages" {
  alarm_name                = "${local.csi}-outstanding-messages"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = 1
  alarm_description         = "This metric monitors unexpected outstanding messages"

  metric_query {
    id          = "sum_outstanding_messages_count"
    expression  = "SELECT SUM(OutstandingMessagesCount) FROM \"Notify/Watchdog\""
    return_data = "true"
    period      = 10800
  }
}
