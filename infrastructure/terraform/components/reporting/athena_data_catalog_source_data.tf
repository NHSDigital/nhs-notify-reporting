resource "aws_athena_data_catalog" "source_data" {
  name        = "${local.csi}-core-glue-data-catalog"
  description = "Source Data Catalog for the ${local.csi} environment"
  type        = "GLUE"

  parameters = {
    "catalog-id" = "${var.core_account_id}"
  }
}
