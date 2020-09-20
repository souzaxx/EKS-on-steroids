awsRegion: ${awsRegion}

autoDiscovery:
  enabled: true

autoDiscovery:
  enable: true
  clusterName: ${clusterName}

rbac:
  create: true
  serviceAccount:
    name: ${clusterName}
    annotations:
      eks.amazonaws.com/role-arn: ${serviceAccountRoleArn}
