terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}
resource "aws_ecr_repository" "backend_docker_image" {
  name = "backend_docker_image"
  force_delete = true
}
data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password  = data.aws_ecr_authorization_token.token.password
  }
}

// platform build workaround
resource "null_resource" "docker_build" {
  provisioner "local-exec" {
    command = "docker buildx build --platform linux/amd64 -t ${aws_ecr_repository.backend_docker_image.repository_url}:latest app/backend"
  }
  depends_on = [aws_ecr_repository.backend_docker_image]
}

//docker login
resource "null_resource" "docker_login" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_ecr_authorization_token.token.proxy_endpoint}"
  }
  depends_on = [null_resource.docker_build]
}

// platform build workaround
resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.backend_docker_image.repository_url}:latest"
  }
  depends_on = [null_resource.docker_login]
}

/* Does not support platform build
resource "docker_image" "backend-docker-image" {
  name = "${aws_ecr_repository.backend_docker_image.repository_url}:latest"
  build {
    context = "app/backend"
    build_args = {
      platform = "linux/amd64"
    }
  }
}


resource "docker_registry_image" "media-handler" {
  name = aws_ecr_repository.backend_docker_image.repository_url
}
*/