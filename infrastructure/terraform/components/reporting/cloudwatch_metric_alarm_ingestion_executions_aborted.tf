resource "aws_cloudwatch_metric_alarm" "ingestion_executions_aborted" {
  alarm_name          = "${local.csi}-ingestion-execution-aborted"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ExecutionsAborted"
  namespace           = "AWS/States"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This metric monitors failed step function executions"
  treat_missing_data  = "notBreaching"

  dimensions = {
    StateMachineArn = aws_sfn_state_machine.ingestion.arn
  }
}
