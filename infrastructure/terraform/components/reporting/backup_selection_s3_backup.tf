resource "aws_backup_selection" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  iam_role_arn = aws_iam_role.s3_backup[0].arn
  name         = "${local.csi}-s3"
  plan_id      = aws_backup_plan.s3_backup[0].id

  resources = [
    aws_s3_bucket.data.arn,
  ]
}
