resource "null_resource" "latency_percentiles_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/latency_percentiles.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        latency_percentiles
    EOT
  }

  depends_on = [
    null_resource.raw_latency_3m_view
  ]
}
