resource "aws_ssm_parameter" "example" {
  name        = "/example/parameter"
  description = "example param"
  type        = "SecureString"
  value       = "example_value"

  tags = {
    environment = "main"
  }
}
