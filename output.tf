output "update_kubeconfig" {
  value = "aws eks update-kubeconfig --name ${local.cluster_name}"
}

output example {
  value = data.aws_subnet.secondary_cidr.*
}