resource "aws_athena_named_query" "overdue_requests" {
  name        = "overdue_requests"
  description = "Query to determine any unexpected/overdue requests"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/watchdog/overdue_requests.sql")

  depends_on = [
    null_resource.request_item_status_table
  ]
}
