resource "null_resource" "request_item_status_table" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/create_table.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        ${aws_s3_bucket.data.bucket} \
        request_item_status
    EOT
  }
}

resource "null_resource" "request_item_status_patientodscode_column" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/add_column.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_status patientodscode string
    EOT
  }

  depends_on = [null_resource.request_item_status_table]
}

resource "null_resource" "request_item_status_requestitemrefid_column" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/add_column.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_status requestitemrefid string
    EOT
  }

  depends_on = [null_resource.request_item_status_patientodscode_column]
}

resource "null_resource" "request_item_status_sendinggroupidversion_column" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/add_column.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_status sendinggroupidversion string
    EOT
  }

  depends_on = [null_resource.request_item_status_requestitemrefid_column]
}

resource "null_resource" "request_item_status_sendinggroupname_column" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/add_column.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_status sendinggroupname string
    EOT
  }

  depends_on = [null_resource.request_item_status_sendinggroupidversion_column]
}

resource "null_resource" "request_item_status_sendinggroupcreateddate_column" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/scripts/add_column.sh \
        ${aws_athena_workgroup.setup.name} \
        ${aws_glue_catalog_database.reporting.name} \
        request_item_status sendinggroupcreateddate string
    EOT
  }

  depends_on = [null_resource.request_item_status_sendinggroupname_column]
}
