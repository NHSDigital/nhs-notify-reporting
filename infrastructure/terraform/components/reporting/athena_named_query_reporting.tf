resource "aws_athena_named_query" "reporting" {
  name        = "${local.csi}-reporting"
  description = "Simple named query for ${local.csi}"
  workgroup   = aws_athena_workgroup.reporting.id
  database    = "${aws_athena_data_catalog.reporting.name}.comms-${local.parameter_bundle.environment}-api-rpt-reporting"
  query       = "SELECT * FROM transaction_history limit 10;"
}
