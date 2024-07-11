###
# Default provider, used for all deployments to eu-west-2
# If no provider name is supplied for a resource then it uses this one
###
provider "aws" {
  region = var.region

  default_tags {
    tags = local.deployment_default_tags
  }
}

###
# Provider specifically for deploying to us-east-1, e.g. for cloudfront, ACM, etc.
###
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = local.deployment_default_tags
  }
}
