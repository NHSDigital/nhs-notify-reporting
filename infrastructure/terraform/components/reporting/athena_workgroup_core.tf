resource "aws_athena_workgroup" "core" {
  name          = "${local.csi}-core"
  description   = "Athena Workgroup for core egress queries in ${local.parameter_bundle.environment} environment"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = false

    result_configuration {
      expected_bucket_owner = local.this_account
      output_location       = "s3://${aws_s3_bucket.results.bucket}/core/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.s3.arn
      }
    }
  }
}
