resource "null_resource" "raw_latency_3m_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/raw_latency_3m.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        raw_latency_3m
    EOT
  }

  depends_on = [
    null_resource.request_item_status_table,
    null_resource.request_item_plan_status_table
  ]
}
