resource "aws_glue_catalog_database" "reporting" {
  name        = "${local.csi}-database"
  description = "Reporting database for ${local.parameter_bundle.environment}"
}
