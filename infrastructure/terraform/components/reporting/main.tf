resource "aws_ssm_parameter" "example" {
  name  = "/example/parameter"
  type  = "SecureString"
  value = "example_value"
}
