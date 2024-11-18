resource "aws_iam_role_policy_attachment" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  role       = aws_iam_role.s3_backup[0].name
  policy_arn = aws_iam_policy.s3_backup[0].arn
}
