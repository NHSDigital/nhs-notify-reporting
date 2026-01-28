resource "aws_cloudwatch_metric_alarm" "patch_task_failed" {
  count = var.enable_powerbi_gateway ? 1 : 0

  alarm_name          = "${local.csi}-patch-task-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedCommands"
  namespace           = "AWS/SSM-RunCommand"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when the AWS-RunPatchBaseline maintenance window task reports a failed run"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DocumentName = "AWS-RunPatchBaseline"
  }
}
