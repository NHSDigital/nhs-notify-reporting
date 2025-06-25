# From Support ticket: Where the client is looking to enable bucket keys on the target S3 bucket, the recommended approach would be:
# 1. Remove the KMS key from the Athena workgroup's encryption configuration: Since the bucket keys will be handling the encryption, you don't need the additional layer of encryption from the workgroup-level KMS key. Removing it will simplify the configuration.
# 2. Rely solely on the bucket keys for encryption: With the bucket keys enabled on the S3 bucket, Athena will automatically use that for encrypting and decrypting the query results. This will reduce the no of API calls.
#trivy:ignore:aws-athena-enable-at-rest-encryption
resource "aws_athena_workgroup" "core" {
  name          = "${local.csi}-core"
  description   = "Athena Workgroup for core egress queries in ${local.parameter_bundle.environment} environment"
  force_destroy = true

  configuration {
    # The Completed Comms and Completed Batch reports both rely on being able to specify the 'output_location'.
    # 'enforce_workgroup_configuration = true' silently ignores the output_location specified by the reports and saves everything to the root of the bucket.
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
