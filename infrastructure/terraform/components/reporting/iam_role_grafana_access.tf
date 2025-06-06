resource "aws_iam_role" "grafana_access" {
  name               = replace("${local.csi}-obs-cross-access-role", "-${var.component}", "")
  description        = "IAM role for Grafana workspace to access this account"
  assume_role_policy = data.aws_iam_policy_document.observability_grafana_role_assume_role_policy.json
}

data "aws_iam_policy_document" "observability_grafana_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.observability_account_id}:root"
      ]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"

      values = [
        "arn:aws:iam::${var.observability_account_id}:role/*obs-workspace-role"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "grafana_workspace_cloudwatch" {
  role       = aws_iam_role.grafana_access.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
