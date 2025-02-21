output "eks_oidc_issuer" {
  description = "OIDC issuer URL"
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "eks_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "eks_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks.endpoint
}