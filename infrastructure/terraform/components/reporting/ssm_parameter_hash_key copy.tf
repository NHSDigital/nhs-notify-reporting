resource "aws_ssm_parameter" "bob_client_ids" {
  name        = "/${local.csi}/bob/clientIds"
  description = "List of client ids to for which to generate bob report"
  type        = "String"
  value       = "[]"
}

