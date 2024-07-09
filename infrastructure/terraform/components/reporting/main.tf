resource "aws_ssm_parameter" "example" {
  name  = "/example/parameter"
  type  = "String"
  value = "example_value"
}