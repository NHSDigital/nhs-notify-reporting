resource "aws_cloudwatch_metric_alarm" "housekeeping_executions_aborted" {
  alarm_name                = "${local.csi}-housekeeping-execution-aborted"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "ExecutionsAborted"
  namespace                 = "AWS/States"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "This metric monitors failed step function executions"

  dimensions = {
    StateMachineArn = aws_sfn_state_machine.housekeeping.arn
  }
}
