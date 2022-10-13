# Created VPC using module due to main focus is on application.
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "3.14.0"
  name                   = var.vpc_name
  cidr                   = var.cidr
  azs                    = var.az
  public_subnets         = var.public_subnets
  private_subnets        = var.private_subnets
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = false

  tags = {
    terraform = true
  }
}
