resource "aws_athena_workgroup" "core" {
  name          = "${local.csi}-core"
  description   = "Athena Workgroup for core egress queries in ${local.parameter_bundle.environment} environment"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = false

    result_configuration {
      expected_bucket_owner = var.core_account_id
      output_location       = "s3://comms-${var.core_account_id}-${var.region}-${var.core_env}-api-rpt-ingress/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = "arn:aws:kms:${var.region}:${var.core_account_id}:alias/comms-${var.core_env}-api-s3"
      }

      acl_configuration {
        s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
      }
    }
  }
}
