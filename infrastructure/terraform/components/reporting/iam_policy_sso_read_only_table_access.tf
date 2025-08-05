resource "aws_iam_policy" "sso_read_only_table_access" {
  count       = var.is_primary_environment ? 1 : 0

  name        = "sso-read-only-table-access"
  description = "IAM Policy for SSO Read Only Table Access"
  policy      = data.aws_iam_policy_document.sso_read_only_table_access[0].json
}
