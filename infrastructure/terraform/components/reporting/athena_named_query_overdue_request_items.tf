resource "aws_athena_named_query" "overdue_request_items" {
  name        = "overdue_request_items"
  description = "Query to determine any unexpected/overdue request items"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/watchdog/overdue_request_items.sql")

  depends_on = [
    null_resource.request_item_status_summary_table
  ]
}
