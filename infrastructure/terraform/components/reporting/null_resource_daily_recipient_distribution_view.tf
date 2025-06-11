resource "null_resource" "daily_recipient_distribution_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/daily_recipient_distribution.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        daily_recipient_distribution
    EOT
  }

  depends_on = [
    null_resource.delivered_messages_view
  ]
}
