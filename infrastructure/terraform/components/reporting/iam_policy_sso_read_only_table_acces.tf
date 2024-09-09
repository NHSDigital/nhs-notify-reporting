resource "aws_iam_policy" "sso_read_only_table_access" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name        = "${local.csi}-sso-read-only-table-access"
  description = "IAM Policy for SSO Read Only Table Access"
  policy      = data.aws_iam_policy_document.sso_read_only_table_access[0].json
}
