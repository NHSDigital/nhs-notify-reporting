resource "aws_athena_workgroup" "user" {
  name          = "${local.csi}-user"
  description   = "Athena Workgroup for user queries in ${local.parameter_bundle.environment} environment blah"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      expected_bucket_owner = local.this_account
      output_location       = "s3://${aws_s3_bucket.reporting.bucket}/output/user/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.s3.arn
      }
    }
  }
}
