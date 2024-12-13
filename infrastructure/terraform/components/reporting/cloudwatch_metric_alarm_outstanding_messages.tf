resource "aws_cloudwatch_metric_alarm" "outstanding_messages" {
  alarm_name                = "${local.csi}-outstanding-messages"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "OutstandingMessageCount"
  namespace                 = "Notify/Watchdog"
  period                    = 86400
  statistic                 = "Minimum"
  threshold                 = 1
  alarm_description         = "This metric monitors unexpected outstanding messages"
}
