resource "aws_athena_named_query" "request_item_plan_summary_ingestion" {
  name        = "request_item_plan_summary_ingestion"
  description = "Updates request_item_plan_summary based upon a moving time window"
  workgroup   = aws_athena_workgroup.ingestion.id
  database    = aws_glue_catalog_database.reporting.name
  query       = "SELECT * FROM \"${aws_athena_data_catalog.source_data.name}\".\"comms-${var.core_env}-api-rpt-reporting\".\"transaction_history\" limit 10"

  depends_on = [aws_athena_data_catalog.source_data, null_resource.request_item_plan_summary_table]
}
