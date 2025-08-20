resource "aws_cloudwatch_log_group" "reporting" {
  name              = "/aws/sfn-state-machine/${local.csi}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_subscription_filter" "reporting" {
  name            = "${local.csi}-reporting"
  log_group_name  = aws_cloudwatch_log_group.reporting.name
  filter_pattern  = ""
  destination_arn = local.log_destination_arn
  role_arn        = local.acct.log_subscription_role_arn
}
