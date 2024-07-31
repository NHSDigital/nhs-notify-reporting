resource "aws_athena_named_query" "completed_request_item_plan_summary_ingestion" {
  name        = "completed_request_item_plan_summary_ingestion"
  description = "Updates completed_request_item_plan_summary based upon a moving time window"
  workgroup   = aws_athena_workgroup.ingestion.id
  database    = aws_glue_catalog_database.reporting.name
  query       = templatefile("${path.module}/scripts/sql/queries/completed_request_item_plan_summary.sql", {
    source_table= "\"${aws_athena_data_catalog.source_data.name}\".\"comms-${var.core_env}-api-rpt-reporting\".\"transaction_history\""
  })

  depends_on = [null_resource.completed_request_item_plan_summary_table]
}
