resource "aws_athena_named_query" "overdue_request_item_plans" {
  name        = "overdue_request_item_plans"
  description = "Query to determine any unexpected/overdue request item plans"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/watchdog/overdue_request_item_plans.sql")

  depends_on = [
    null_resource.request_item_plan_status_table
  ]
}
