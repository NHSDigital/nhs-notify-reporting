resource "aws_athena_named_query" "degraded_latency" {
  name        = "degraded_latency"
  description = "Query to identify if today's latencies are significantly worse than historic values"
  workgroup   = aws_athena_workgroup.user.id
  database    = aws_glue_catalog_database.reporting.name
  query       = file("${path.module}/scripts/sql/watchdog/degraded_latency.sql")

  depends_on = [
    null_resource.raw_latency_3m
  ]
}
