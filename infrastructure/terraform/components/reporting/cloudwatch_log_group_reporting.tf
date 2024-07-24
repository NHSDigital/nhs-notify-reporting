resource "aws_cloudwatch_log_group" "reporting" {
  name = "/aws/sfn-state-machine/${local.csi}"
  retention_in_days = var.log_retention_days
}
