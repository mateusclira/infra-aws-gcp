terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws//?version=3.14.2"
}

include {
  path = find_in_parent_folders()
}

locals {
  region = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region = local.region.locals.region
}

inputs = {
  network_name       = "vpc"
  cidr               = "10.0.0.0/16"

  azs                = [
    "${local.aws_region}a",
    "${local.aws_region}b",
    "${local.aws_region}c"
  ]

  private_subnets    = [
    "10.0.0.0/20",
    "10.0.32.0/20",
    "10.0.64.0/20"
  ]

  public_subnets     = [
    "10.0.96.0/20",
    "10.0.128.0/20",
    "10.0.160.0/20"
  ]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  enable_ipv6        = false
  enable_nat_gateway = true
  single_nat_gateway = true
}
