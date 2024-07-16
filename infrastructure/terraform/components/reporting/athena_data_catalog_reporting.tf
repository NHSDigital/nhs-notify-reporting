resource "aws_athena_data_catalog" "reporting" {
  name        = "${local.csi}-core-glue-data-catalog"
  description = "Glue based Data Catalog for the ${local.csi} Environment"
  type        = "GLUE"

  parameters = {
    "catalog-id" = var.core_account_id
  }
}
