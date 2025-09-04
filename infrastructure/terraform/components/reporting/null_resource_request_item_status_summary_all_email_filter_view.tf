resource "null_resource" "request_item_status_summary_all_email_filter_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/request_item_status_summary_all_email_filter.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_status_summary_all_email_filter
    EOT
  }

  depends_on = [
    null_resource.request_item_status_summary_all_view,
    null_resource.request_item_plan_completed_summary_all_view
  ]
}
