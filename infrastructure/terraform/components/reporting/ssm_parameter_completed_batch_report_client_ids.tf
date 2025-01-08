resource "aws_ssm_parameter" "completed_batch_report_client_ids" {
  name        = "/${local.csi}/completed-batch-report/clientIds"
  description = "List of client ids to for which to generate the completed batch report"
  type        = "String"
  value       = "[]"

  lifecycle {
    ignore_changes = [value]
  }
}

