resource "aws_iam_role" "grafana_access" {
  count              = var.is_primary_environment ? 1 : 0
  name               = replace("${local.csi}-obs-cross-access-role", "-${var.component}", "")
  description        = "IAM role for Grafana workspace to access this account"
  assume_role_policy = data.aws_iam_policy_document.observability_grafana_role_assume_role_policy[0].json
}

data "aws_iam_policy_document" "observability_grafana_role_assume_role_policy" {
  count = var.is_primary_environment ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.shared_infra_account_id}:root"
      ]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"

      values = [
        "arn:aws:iam::${var.shared_infra_account_id}:role/*obs-workspace-role"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "grafana_workspace_cloudwatch" {
  count      = var.is_primary_environment ? 1 : 0
  role       = aws_iam_role.grafana_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
