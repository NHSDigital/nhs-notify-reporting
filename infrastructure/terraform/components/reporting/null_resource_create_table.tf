resource "null_resource" "request_item_plan_summary_table" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create_table.sh ${var.environment} ${aws_s3_bucket.reporting.bucket} request_item_plan_summary"
  }

  depends_on = [aws_athena_workgroup.setup]
}
