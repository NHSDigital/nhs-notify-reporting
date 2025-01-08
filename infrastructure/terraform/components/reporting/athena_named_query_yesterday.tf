resource "aws_athena_named_query" "yesterday" {
  name        = "yesterday"
  description = "Query to determine yesterday's date"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/reports/yesterday.sql")
}
