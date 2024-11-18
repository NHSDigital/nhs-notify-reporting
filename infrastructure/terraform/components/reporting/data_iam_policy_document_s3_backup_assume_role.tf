data "aws_iam_policy_document" "s3_backup_assume_role" {
  count = var.enable_s3_backup ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}
