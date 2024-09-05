resource "null_resource" "request_item_plan_completed_summary_table" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_table.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        ${aws_s3_bucket.data.bucket} \
        request_item_plan_completed_summary
    EOT
  }

  depends_on = [aws_athena_workgroup.setup]
}

resource "null_resource" "contactdetailsource_column" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/add_column.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_plan_completed_summary contactdetailsource string
    EOT
  }

  depends_on = [null_resource.request_item_plan_completed_summary_table]
}
