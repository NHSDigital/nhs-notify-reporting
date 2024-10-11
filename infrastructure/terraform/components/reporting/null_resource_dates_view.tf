resource "null_resource" "dates_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/dates.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        dates
    EOT
  }
}
