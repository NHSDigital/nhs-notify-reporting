# From Support ticket: Where the client is looking to enable bucket keys on the target S3 bucket, the recommended approach would be:
# 1. Remove the KMS key from the Athena workgroup's encryption configuration: Since the bucket keys will be handling the encryption, you don't need the additional layer of encryption from the workgroup-level KMS key. Removing it will simplify the configuration.
# 2. Rely solely on the bucket keys for encryption: With the bucket keys enabled on the S3 bucket, Athena will automatically use that for encrypting and decrypting the query results. This will reduce the no of API calls.
#tfsec:ignore:aws-athena-enable-at-rest-encryption
resource "aws_athena_workgroup" "user" {
  name          = "${local.csi}-user"
  description   = "Athena Workgroup for user queries in ${local.parameter_bundle.environment} environment"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      expected_bucket_owner = local.this_account
      output_location       = "s3://${aws_s3_bucket.results.bucket}/user/"
    }
  }
}
