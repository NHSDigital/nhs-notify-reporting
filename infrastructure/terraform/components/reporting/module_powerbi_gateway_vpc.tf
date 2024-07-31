module "powerbi_gateway_vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"  # Adjust to the latest version

  create_vpc = var.enable_powerbi_gateway

  name = "${local.csi}-powerbi-gateway-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.availability_zones
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = false
  enable_dns_support = true
  enable_dns_hostnames = true
  create_igw = true

}

resource "aws_security_group" "powerbi_gateway" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name   = "${local.csi}-powerbi-gateway-security-group"
  vpc_id = module.powerbi_gateway_vpc.vpc_id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 9350
    to_port     = 9354
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.csi}-powerbi-gateway-sg"
  }
}
