resource "aws_athena_named_query" "completed_batches" {
  name        = "completed_batches"
  description = "Query to determine which batches have recently completed"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/reports/completed_batches.sql")

  depends_on = [
    null_resource.request_item_status_table
  ]
}
