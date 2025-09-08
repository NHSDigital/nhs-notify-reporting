resource "null_resource" "letters_invoice_units_monthly_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/letters_invoice_units_monthly.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        letters_invoice_units_monthly
    EOT
  }

  depends_on = [
    null_resource.request_item_plan_status_table
  ]
}
