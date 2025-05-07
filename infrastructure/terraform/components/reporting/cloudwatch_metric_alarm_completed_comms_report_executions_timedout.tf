resource "aws_cloudwatch_metric_alarm" "completed_comms_report_executions_timedout" {
  alarm_name          = "${local.csi}-completed-comms-report-executions-timedout"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ExecutionsTimedOut"
  namespace           = "AWS/States"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This metric monitors step function execution timeouts"
  treat_missing_data  = "notBreaching"

  dimensions = {
    StateMachineArn = aws_sfn_state_machine.completed_comms_report.arn
  }
}
