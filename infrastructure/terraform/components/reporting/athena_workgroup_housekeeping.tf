# From Support ticket: Where the client is looking to enable bucket keys on the target S3 bucket, the recommended approach would be:
# 1. Remove the KMS key from the Athena workgroup's encryption configuration: Since the bucket keys will be handling the encryption, you don't need the additional layer of encryption from the workgroup-level KMS key. Removing it will simplify the configuration.
# 2. Rely solely on the bucket keys for encryption: With the bucket keys enabled on the S3 bucket, Athena will automatically use that for encrypting and decrypting the query results. This will reduce the no of API calls.
#trivy:ignore:aws-athena-enable-at-rest-encryption
resource "aws_athena_workgroup" "housekeeping" {
  name          = "${local.csi}-housekeeping"
  description   = "Athena Workgroup for housekeeping queries in ${local.parameter_bundle.environment} environment"
  force_destroy = true

  #trivy:ignore:aws-athena-no-encryption-override At AWS Support suggestion
  configuration {
    enforce_workgroup_configuration = false

    result_configuration {
      expected_bucket_owner = local.this_account
      output_location       = "s3://${aws_s3_bucket.results.bucket}/housekeeping/"
    }
  }
}
