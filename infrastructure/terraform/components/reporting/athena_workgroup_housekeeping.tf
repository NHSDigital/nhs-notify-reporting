resource "aws_athena_workgroup" "housekeeping" {
  name          = "${local.csi}-housekeeping"
  description   = "Athena Workgroup for housekeeping queries in ${local.parameter_bundle.environment} environment"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      expected_bucket_owner = local.this_account
      output_location       = "s3://${aws_s3_bucket.results.bucket}/housekeeping/"
    }
  }
}
