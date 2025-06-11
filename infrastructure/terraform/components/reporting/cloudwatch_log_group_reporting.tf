resource "aws_cloudwatch_log_group" "reporting" {
  name              = "/aws/sfn-state-machine/${local.csi}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_subscription_filter" "reporting" {
  name            = "${local.csi}-reporting"
  log_group_name  = aws_cloudwatch_log_group.reporting.name
  filter_pattern  = ""
  destination_arn = "arn:aws:logs:${var.region}:${var.observability_account_id}:destination:nhs-notify-main-acct-firehose-logs"
  role_arn        = local.acct.log_subscription_role_arn
}
