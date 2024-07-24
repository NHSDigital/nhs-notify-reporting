data "aws_iam_roles" "sso_administrator_local" {
  name_regex  = "AWSReservedSSO_nhs-notify-admin_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}