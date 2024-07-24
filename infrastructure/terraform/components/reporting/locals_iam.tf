locals {
  iam_resource_arns = {
    admin_local                         = tolist(data.aws_iam_roles.sso_administrator_local.arns)[0]
    any_authorised_user_in_this_account = "arn:aws:iam::${local.this_account}:root"
  }
}
