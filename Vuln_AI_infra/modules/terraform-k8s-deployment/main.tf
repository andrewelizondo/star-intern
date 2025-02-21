// === Kubernetes Deployment ===

provider "kubernetes" {
  host = var.eks_endpoint
  token = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(var.eks_certificate_authority_data)
}

# Create a Secret for ECR
resource "kubernetes_secret" "docker" {
  metadata {
    name      = "ecr-auth"
    namespace = kubernetes_namespace.backend-namespace.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.ecr_authorization_token_proxy_endpoint}" = {
          auth = "${var.ecr_authorization_token}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

data "aws_eks_cluster_auth" "cluster" { name = var.eks_cluster_name}

resource "kubernetes_namespace" "backend-namespace" {
  metadata {
    name = "backend-namespace"
  }
}

resource "kubernetes_service_account" "bedrock-service-account" {
  metadata {
    name      = "bedrock-service-account"
    namespace = "backend-namespace"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.eks_irsa_role_arn
    }
  }
}

resource "kubernetes_deployment" "backend-deploy" {
  metadata {
    name = "backenddeployment"
    labels = {
      test = "backenddeployment"
    }
    namespace = kubernetes_namespace.backend-namespace.metadata.0.name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "backend"
      }
    }

    template {
      metadata {
        labels = {
          test = "backend"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.bedrock-service-account.metadata.0.name
        image_pull_secrets {
          name = "ecr-auth"
        }
        container {
          image = var.container_image_name //"${aws_ecr_repository.backend_docker_image.repository_url}:latest"
          name  = "backend"
          env {
            name = "AGENT_ID"
            value = var.agent_id
          }
          env {
            name = "AGENT_ALIAS_ID"
            value = var.agent_alias_id
          }
          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend-service" {
  metadata {
    name = "backendservice"
    namespace = kubernetes_namespace.backend-namespace.metadata.0.name
  }

  spec {
    selector = {
      test = "backend"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

data "kubernetes_service" "backend_service_ingress" {
  metadata {
    name      = "backendservice"
    namespace = "backend-namespace"
  }

  depends_on = [ kubernetes_service.backend-service ]
}