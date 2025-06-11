resource "null_resource" "delivered_messages_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/delivered_messages.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        delivered_messages
    EOT
  }

  depends_on = [
    null_resource.request_item_status_table
  ]
}
