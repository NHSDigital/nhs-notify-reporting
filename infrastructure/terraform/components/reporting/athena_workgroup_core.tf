resource "aws_athena_workgroup" "core" {
  name          = "${local.csi}-core"
  description   = "Athena Workgroup for core egress queries in ${local.parameter_bundle.environment} environment"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = false

    result_configuration {
      expected_bucket_owner = var.core_account_id
      output_location       = "s3://comms-${var.core_account_id}-eu-west-2-${var.core_env}-api-rpt-ingress/"

      acl_configuration {
        s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
      }
    }
  }
}
