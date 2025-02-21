output "eks_irsa_role_arn" {
  value = aws_iam_role.eks-irsa-role.arn
}