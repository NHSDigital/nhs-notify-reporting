resource "aws_athena_named_query" "completed_comms_report" {
  name        = "completed_comms_report"
  description = "Runs the query to generate the completed communications report, writing the results back to the core account"
  workgroup   = aws_athena_workgroup.core.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/reports/completed_comms_report.sql")

  depends_on = [
    null_resource.request_item_status_table,
    null_resource.request_item_plan_status_table
  ]
}
