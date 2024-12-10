resource "aws_athena_named_query" "outstanding_requests" {
  name        = "outstanding_requests"
  description = "Query to determine any unexpected outstanding requests"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/watchdog/outstanding_requests.sql")

  depends_on = [
    null_resource.request_item_status_table
  ]
}
