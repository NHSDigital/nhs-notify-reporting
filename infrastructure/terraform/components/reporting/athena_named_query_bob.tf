resource "aws_athena_named_query" "bob" {
  name        = "bob"
  description = "Runs the bob report"
  workgroup   = aws_athena_workgroup.core.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/egress/bob.sql")

  depends_on = [
    null_resource.request_item_status_table,
    null_resource.request_item_plan_status_table
  ]
}
