module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.17"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  enable_irsa     = true

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  worker_groups_launch_template = [
    {
      name                     = "spot-1"
      spot_allocation_strategy = "capacity-optimized"
      override_instance_types  = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
      on_demand_base_capacity  = "1"
      spot_instance_pools      = null
      asg_max_size             = 5
      asg_desired_capacity     = 1
      kubelet_extra_args       = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip                = true
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
  ]


  # node_groups_defaults = {
  #   ami_type  = "AL2_x86_64"
  #   disk_size = 50
  # }

  # node_groups = {
  #   example = {
  #     desired_capacity = 1
  #     max_capacity     = 10
  #     min_capacity     = 1

  #     instance_type = "m5.large"
  #     k8s_labels = {
  #       Environment = "test"
  #       GithubRepo  = "terraform-aws-eks"
  #       GithubOrg   = "terraform-aws-modules"
  #     }
  #     additional_tags = {
  #       "k8s.io/cluster-autoscaler/enabled"   = true,
  #       "k8s.io/cluster-autoscaler/${local.cluster_name}"   = true,
  #       ExtraTag = "example"
  #     }
  #   }
  # }
}
