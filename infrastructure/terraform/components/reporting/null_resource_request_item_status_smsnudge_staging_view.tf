resource "null_resource" "request_item_status_smsnudge_staging_view" {
  triggers = {
    sql = filesha256("${path.module}/scripts/sql/views/request_item_status_smsnudge_staging.sql")
  }

  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_replace_view.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_status_smsnudge_staging \
        sms_nudge_client_id "${local.sms_nudge_client_id}"
    EOT
  }

  depends_on = [
    null_resource.request_item_status_table
  ]
}
