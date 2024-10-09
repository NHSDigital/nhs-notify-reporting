resource "aws_athena_named_query" "request_item_plan_completed_summary_batch" {
  name        = "request_item_plan_completed_summary_batch"
  description = "Updates request_item_plan_completed_summary_batch table based upon a moving time window"
  workgroup   = aws_athena_workgroup.ingestion.id
  database    = aws_glue_catalog_database.reporting.name
  query       = templatefile("${path.module}/scripts/sql/ingestion/request_item_plan_completed_summary_batch.sql", {
    batch_client_ids = join(", ", [for id in var.batch_client_ids : format("'%s'", id)])
  })

  depends_on = [null_resource.request_item_plan_completed_summary_batch_table]
}

resource "aws_athena_named_query" "request_item_plan_completed_summary_batch_vacuum" {
  name        = "request_item_plan_completed_summary_batch_vacuum"
  description = "Perform vacuum operation to remove old snapshots"
  workgroup   = aws_athena_workgroup.housekeeping.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/vacuum/request_item_plan_completed_summary_batch.sql")

  depends_on = [null_resource.request_item_plan_completed_summary_batch_table]
}

resource "aws_athena_named_query" "request_item_plan_completed_summary_batch_optimize" {
  name        = "request_item_plan_completed_summary_batch_optimize"
  description = "Optiizes storage by rewriting data files "
  workgroup   = aws_athena_workgroup.housekeeping.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/optimize/request_item_plan_completed_summary_batch.sql")

  depends_on = [null_resource.request_item_plan_completed_summary_batch_table]
}
