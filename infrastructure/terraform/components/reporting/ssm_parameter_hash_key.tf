resource "aws_ssm_parameter" "hash_key" {
  name        = "/${local.csi}/hash_key"
  description = "Random key used to generate distinct environment-specific hash values"
  type        = "SecureString"
  value       = random_bytes.hash_key.base64
}

resource "random_bytes" "hash_key" {
  length = 32
}
