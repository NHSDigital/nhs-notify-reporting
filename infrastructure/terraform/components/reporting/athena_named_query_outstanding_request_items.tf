resource "aws_athena_named_query" "outstanding_request_items" {
  name        = "outstanding_request_items"
  description = "Query to determine any unexpected/overdue outstanding request items"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/watchdog/outstanding_request_items.sql")

  depends_on = [
    null_resource.request_item_status_summary_table
  ]
}
