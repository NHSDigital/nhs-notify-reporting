resource "aws_athena_workgroup" "ingestion" {
  name          = local.csi
  description   = "Athena Workgroup for ${local.parameter_bundle.environment} data ingestion"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      expected_bucket_owner = local.this_account
      output_location       = "s3://${aws_s3_bucket.reporting.bucket}/ingestion/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.s3.arn
      }
    }
  }
}
