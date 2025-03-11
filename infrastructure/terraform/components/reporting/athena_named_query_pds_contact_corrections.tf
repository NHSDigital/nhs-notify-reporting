resource "aws_athena_named_query" "pds_contact_corrections" {
  name        = "pds_contact_corrections"
  description = "Query to report which pds changes may have resulted in the correction of a temporary or permanent failure"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/reports/pds_contact_corrections.sql")

  depends_on = [
    null_resource.request_item_status_table,
    null_resource.request_item_plan_status_table
  ]
}
