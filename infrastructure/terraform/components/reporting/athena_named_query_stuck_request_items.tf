resource "aws_athena_named_query" "stuck_request_items" {
  name        = "stuck_request_items"
  description = "Query to determine any request items unexpectedly stuck in an ENRICHED or PENDING_ENRICHMENT state"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/watchdog/stuck_request_items.sql")

  depends_on = [
    null_resource.request_item_status_table
  ]
}
