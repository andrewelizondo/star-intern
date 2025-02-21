variable eks_cluster_name {
  description = "EKS cluster name"
  type        = string
}

variable eks_endpoint {
  description = "EKS cluster endpoint"
  type        = string
}

variable eks_certificate_authority_data {
  description = "EKS certificate authority data"
  type        = string
}

variable ecr_authorization_token {
  description = "ECR authorization token"
  type        = string
}

variable ecr_authorization_token_proxy_endpoint {
  description = "ECR authorization token proxy endpoint"
  type        = string
}

variable eks_irsa_role_arn {
  description = "EKS IRSA role ARN"
  type        = string
}

variable container_image_name {
  description = "Container image name"
  type        = string
}

variable agent_id {
  description = "Agent ID"
  type        = string
}

variable agent_alias_id {
  description = "Agent alias ID"
  type        = string
}