resource "null_resource" "request_item_plan_read_status_smsnudge" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/request_item_plan_read_status_smsnudge.sql")
  }

  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_plan_read_status_smsnudge \
        sms_nudge_client_id "${local.sms_nudge_client_id}"
    EOT
  }

  depends_on = [
    null_resource.request_item_plan_status_table,
    null_resource.request_item_plan_status_smsnudge_view
  ]
}
