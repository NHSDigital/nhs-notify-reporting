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

resource "aws_athena_named_query" "request_item_plan_completed_summary_vacuum" {
  name        = "request_item_plan_completed_summary_vacuum"
  description = "Perform vacuum operation to remove old snapshots"
  workgroup   = aws_athena_workgroup.housekeeping.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/vacuum/request_item_plan_completed_summary.sql")

  depends_on = [null_resource.request_item_plan_completed_summary_table]
}

resource "aws_athena_named_query" "request_item_plan_completed_summary_optimize" {
  name        = "request_item_plan_completed_summary_optimize"
  description = "Optiizes storage by rewriting data files "
  workgroup   = aws_athena_workgroup.housekeeping.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/optimize/request_item_plan_completed_summary.sql")

  depends_on = [null_resource.request_item_plan_completed_summary_table]
}
