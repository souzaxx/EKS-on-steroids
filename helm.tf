resource "null_resource" "aws_vpc_cni_relabel" {

  provisioner "local-exec" {
    command = <<EOF
      for kind in daemonSet clusterRole clusterRoleBinding serviceAccount; do
        echo "setting annotations and labels on $kind/aws-node"
        kubectl --kubeconfig ${module.eks.kubeconfig_filename} -n kube-system annotate --overwrite $kind aws-node meta.helm.sh/release-name=aws-vpc-cni
        kubectl --kubeconfig ${module.eks.kubeconfig_filename} -n kube-system annotate --overwrite $kind aws-node meta.helm.sh/release-namespace=kube-system
        kubectl --kubeconfig ${module.eks.kubeconfig_filename} -n kube-system label    --overwrite $kind aws-node app.kubernetes.io/managed-by=Helm
      done
EOF
  }

  depends_on = [
    module.eks.kubeconfig
  ]
}

resource "helm_release" "aws_vpc_cni" {
  name       = "aws-vpc-cni"
  repository = "${path.module}/charts"
  chart      = "aws-vpc-cni"
  namespace  = "kube-system"

  values = [templatefile("${path.module}/templates/aws-vpc-cni.yaml.tpl", {
    subnets              = data.aws_subnet.secondary_cidr.*,
    security_groups      = [module.eks.security_group_rule_cluster_https_worker_ingress[0].source_security_group_id],
    enable_custom_config = true
  })]

  depends_on = [
    null_resource.aws_vpc_cni_relabel
  ]
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler-chart"
  namespace  = "kube-system"
  version    = "1.0.1"

  values = [templatefile("${path.module}/templates/cluster-autoscaler-chart.yaml.tpl", {
    awsRegion             = data.aws_region.current.name
    clusterName           = local.cluster_name
    serviceAccountName    = local.k8s_service_account_name
    serviceAccountRoleArn = module.cluster_autoscaler.this_iam_role_arn
  })]

  depends_on = [
    helm_release.aws_vpc_cni
  ]
}

resource "helm_release" "node_termination" {
  name       = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  namespace  = "kube-system"
  version    = "0.9.5"

  depends_on = [
    helm_release.aws_vpc_cni
  ]
}

resource "helm_release" "metric_server" {
  name       = "metric-server"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "2.11.1"

  values = [<<EOF
args: [ "--kubelet-preferred-address-types=InternalIP" ]
EOF
  ]

  depends_on = [
    helm_release.aws_vpc_cni
  ]
}

