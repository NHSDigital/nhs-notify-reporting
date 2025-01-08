resource "aws_cloudwatch_metric_alarm" "completed_batch_report_executions_failed" {
  alarm_name                = "${local.csi}-completed-batch-report-executions-failed"
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
    StateMachineArn = aws_sfn_state_machine.completed_batch_report.arn
  }
}
