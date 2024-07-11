resource "null_resource" "create_table" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create_iceberg_table.sh ${var.environment}"
  }

  depends_on = [aws_athena_workgroup.daily_report]
}
