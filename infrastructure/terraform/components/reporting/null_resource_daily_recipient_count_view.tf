resource "null_resource" "daily_recipient_count_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/daily_recipient_count.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        daily_recipient_count
    EOT
  }

  depends_on = [
    null_resource.request_item_status_table
  ]
}
