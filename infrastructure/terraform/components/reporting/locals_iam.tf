locals {
  iam_resource_arns = {
    any_authorised_user_in_this_account = "arn:aws:iam::${local.this_account}:root"
  }
}
