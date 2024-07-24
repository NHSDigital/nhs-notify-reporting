resource "aws_cloudwatch_metric_alarm" "executions_failed" {
  alarm_name                = "${local.csi}-executions-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "ExecutionsFailed"
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
