// === IRSA ===

data "tls_certificate" "tls_cert" {
  url = var.eks_oidc_issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_cert.certificates[0].sha1_fingerprint]
  url             = var.eks_oidc_issuer
}

resource "aws_iam_role" "eks-irsa-role" {
  name = "eks-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = ""
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc_provider.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${aws_iam_openid_connect_provider.oidc_provider.url}:sub" = "system:serviceaccount:backend-namespace:bedrock-service-account"
          "${aws_iam_openid_connect_provider.oidc_provider.url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "eks-irsa-policy" {
  name   = "eks-irsa-policy"
  role   = aws_iam_role.eks-irsa-role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      Resource = "*"
    },
    {
      Effect = "Allow",
      Action = [
        "bedrock:InvokeAgent",
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_irsa_admin_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks-irsa-role.name
}