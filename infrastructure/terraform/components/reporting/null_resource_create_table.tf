resource "null_resource" "create_table" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create_iceberg_table.sh ${var.environment} ${local.this_account}"
  }

  depends_on = [aws_athena_workgroup.setup, aws_athena_workgroup.ingestion]
}
