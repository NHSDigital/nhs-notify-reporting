resource "null_resource" "request_item_plan_completed_summary_table" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create_table.sh ${var.environment} ${aws_s3_bucket.data.bucket} request_item_plan_completed_summary"
  }

  depends_on = [aws_athena_workgroup.setup]
}
