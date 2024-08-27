resource "aws_athena_named_query" "request_item_plan_completed_summary" {
  name        = "request_item_plan_completed_summary"
  description = "Updates request_item_plan_completed_summary table based upon a moving time window"
  workgroup   = aws_athena_workgroup.ingestion.id
  database    = aws_glue_catalog_database.reporting.name
  query       = templatefile("${path.module}/scripts/sql/queries/request_item_plan_completed_summary.sql", {
    source_table= "\"${aws_athena_data_catalog.source_data.name}\".\"comms-${var.core_env}-api-rpt-reporting\".\"transaction_history\""
  })

  depends_on = [null_resource.request_item_plan_completed_summary_table]
}
