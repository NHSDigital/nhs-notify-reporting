resource "null_resource" "monthly_messages_per_recipient_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/monthly_messages_per_recipient.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        monthly_messages_per_recipient
    EOT
  }

  depends_on = [
    null_resource.delivered_messages_view
  ]
}
