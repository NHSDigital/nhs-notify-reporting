resource "aws_athena_named_query" "outstanding_messages" {
  name        = "outstanding_messages"
  description = "Query to determine any unexpected outstanding messages"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/watchdog/outstanding_messages.sql")

  depends_on = [
    null_resource.request_item_status_summary_table
  ]
}
