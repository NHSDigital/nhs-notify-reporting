resource "aws_athena_named_query" "client_latest_name" {
  name        = "client_latest_name"
  description = "Updates client_latest_name table based upon clientId and timestamp of last update"
  workgroup   = aws_athena_workgroup.ingestion.id
  database    = aws_glue_catalog_database.reporting.name
  query = templatefile("${path.module}/scripts/sql/ingestion/client_latest_name.sql", {
    source_table = "\"${aws_athena_data_catalog.source_data.name}\".\"comms-${var.core_env}-api-rpt-reporting\".\"transaction_history\""
  })

  depends_on = [null_resource.client_latest_name_table]
}

resource "aws_athena_named_query" "client_latest_name_vacuum" {
  name        = "client_latest_name_vacuum"
  description = "Perform vacuum operation to remove old snapshots"
  workgroup   = aws_athena_workgroup.housekeeping.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/vacuum/request_item_plan_completed_summary_batch.sql")

  depends_on = [null_resource.client_latest_name_table]
}

resource "aws_athena_named_query" "client_latest_name_optimize" {
  name        = "client_latest_name_optimize"
  description = "Optimizes storage by rewriting data files "
  workgroup   = aws_athena_workgroup.housekeeping.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/optimize/request_item_plan_completed_summary_batch.sql")

  depends_on = [null_resource.client_latest_name_table]
}