resource "aws_ssm_parameter" "completed_comms_report_client_ids" {
  name        = "/${local.csi}/completed_comms_report/clientIds"
  description = "List of client ids to for which to generate the completed communications report"
  type        = "String"
  value       = "[]"

  lifecycle {
    ignore_changes = [value]
  }
}

