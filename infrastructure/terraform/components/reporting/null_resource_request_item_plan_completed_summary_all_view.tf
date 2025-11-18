resource "null_resource" "request_item_plan_completed_summary_all_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/request_item_plan_completed_summary_all.sql")
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_plan_completed_summary_all
    EOT
  }

  depends_on = [
    null_resource.request_item_plan_completed_summary_table,
    null_resource.request_item_plan_completed_summary_batch_table
  ]
}
