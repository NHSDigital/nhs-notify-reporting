resource "aws_athena_workgroup" "setup" {
  name          = "${local.csi}-setup"
  description   = "Athena Workgroup for setup and data migration in ${local.parameter_bundle.environment} environment"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      expected_bucket_owner = local.this_account
      output_location       = "s3://${aws_s3_bucket.results.bucket}/setup/"
    }
  }
}
