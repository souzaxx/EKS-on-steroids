module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.46.0"

  name = "secondary-cidr-blocks-example"

  cidr = "192.168.0.0/22"

  secondary_cidr_blocks = [
    "100.64.0.0/18",
  ]

  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]

  public_subnets = [
    "192.168.0.0/24",
    "192.168.1.0/24",
    "192.168.2.0/24",
  ]

  private_subnets = [
    "100.64.0.0/20",
    "100.64.16.0/20",
    "100.64.32.0/20",
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "kubernetes.io/cluster/cluster-name"          = local.cluster_name,
  }

  vpc_tags = {
    Name = "secondary-cidr-blocks-example"
  }

}
