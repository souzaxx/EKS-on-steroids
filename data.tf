data "aws_eks_cluster" "cluster" { name = module.eks.cluster_id }

data "aws_eks_cluster_auth" "cluster" { name = module.eks.cluster_id }

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnet" "secondary_cidr" {
  count = length(module.vpc.private_subnets)

  vpc_id = module.vpc.vpc_id
  id     = element(module.vpc.private_subnets, count.index)
}