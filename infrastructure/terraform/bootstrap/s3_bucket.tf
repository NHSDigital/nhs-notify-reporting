#trivy:ignore:aws-s3-enable-bucket-logging Bucket exists before anyother bucket can exist
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  force_destroy = false

  # This does not use default tag map merging because bootstrapping is special
  # You should use default tag map merging elsewhere
  tags = merge(
    local.default_tags,
    {
      Name = "Terraform Scaffold State File Bucket for account ${var.aws_account_id} in region ${var.region}"
    }
  )
}
