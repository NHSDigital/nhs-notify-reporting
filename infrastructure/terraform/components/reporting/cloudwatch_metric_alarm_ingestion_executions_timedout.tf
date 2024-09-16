resource "aws_cloudwatch_metric_alarm" "ingestion_executions_timedout" {
  alarm_name                = "${local.csi}-ingestion-executions-timedout"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "ExecutionsTimedOut"
  namespace                 = "AWS/States"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "This metric monitors step function execution timeouts"
  insufficient_data_actions = []

  dimensions = {
    StateMachineArn = aws_sfn_state_machine.ingestion.arn
  }
}
