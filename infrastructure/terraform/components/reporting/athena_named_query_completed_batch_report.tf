resource "aws_athena_named_query" "completed_batch_report" {
  name        = "completed_batch_report"
  description = "Runs the query to generate the completed batch report, writing the results back to the core account"
  workgroup   = aws_athena_workgroup.core.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/reports/completed_batch_report.sql")

  depends_on = [
    null_resource.completed_comms_view
  ]
}
