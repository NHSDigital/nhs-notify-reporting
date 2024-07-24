resource "aws_cloudwatch_metric_alarm" "executions_aborted" {
  alarm_name                = "${local.csi}-execution-aborted"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "ExecutionsAborted"
  namespace                 = "AWS/States"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "This metric monitors failed step function executions"
  insufficient_data_actions = []

  dimensions = {
    StateMachineArn = aws_sfn_state_machine.athena.arn
  }
}
