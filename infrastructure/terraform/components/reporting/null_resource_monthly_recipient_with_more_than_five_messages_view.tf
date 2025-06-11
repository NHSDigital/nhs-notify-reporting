resource "null_resource" "monthly_recipient_with_more_than_five_messages_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/monthly_recipient_with_more_than_five_messages.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        monthly_recipient_with_more_than_five_messages
    EOT
  }

  depends_on = [
    null_resource.delivered_messages_view
  ]
}
