zones:
%{ for subnet in subnets ~}
- name: ${subnet.availability_zone}
  subnetID: ${subnet.id}
%{ endfor ~}
securityGroupIDs:
%{ for sg in security_groups ~}
- ${sg}
%{ endfor ~}
env:
  AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG: ${enable_custom_config}
