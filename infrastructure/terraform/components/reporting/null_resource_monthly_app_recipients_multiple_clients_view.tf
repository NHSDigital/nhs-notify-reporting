resource "null_resource" "monthly_app_recipients_multiple_clients_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/monthly_app_recipients_multiple_clients.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        monthly_app_recipients_multiple_clients
    EOT
  }

  depends_on = [
    null_resource.delivered_messages_view
  ]
}
