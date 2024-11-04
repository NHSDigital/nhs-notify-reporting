resource "null_resource" "request_item_plan_status_table" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_table.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        ${aws_s3_bucket.data.bucket} \
        request_item_plan_status
    EOT
  }
}

resource "null_resource" "request_item_plan_status_sendtime_column" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/add_column.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_plan_status sendtime timestamp
    EOT
  }

  depends_on = [null_resource.request_item_plan_status_table]
}

resource "null_resource" "request_item_plan_status_ordernumber_column" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/add_column.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_plan_status ordernumber int
    EOT
  }

  depends_on = [null_resource.request_item_plan_status_sendtime_column]
}
