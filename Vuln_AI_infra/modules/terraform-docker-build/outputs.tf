output "container_image_name" {
  description = "Container image name"
  value       = "${aws_ecr_repository.backend_docker_image.repository_url}:latest"
}

output "ecr_authorization_token" {
  description = "ECR authorization token"
  value       = data.aws_ecr_authorization_token.token.authorization_token
}

output "ecr_authorization_token_proxy_endpoint" {
  description = "ECR authorization token proxy endpoint"
  value       = data.aws_ecr_authorization_token.token.proxy_endpoint
}