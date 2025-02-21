data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

provider "aws" {
  region = "us-east-1"
}

module "bedrock_agent_code" {
  source = "./modules/terraform-bedrock-agent-code"
    agent_name = "star-intern"
    foundation_model = "amazon.nova-pro-v1:0"
    agent_alias_name = "star_intern_agent_alias"
    agent_alias_description = "Just an alias for the star intern agent"
}

module "docker_build" {
  source = "./modules/terraform-docker-build"
}

module "vpc" {
  source = "./modules/terraform-vpc"
    vpc_name = "eks-vpc"
    vpc_cidr_block = "10.0.0.0/16"
    public_subnet_1_cidr_block = "10.0.1.0/24"
    public_subnet_1_availability_zone = "us-east-1a"
    public_subnet_2_cidr_block = "10.0.2.0/24"
    public_subnet_2_availability_zone = "us-east-1b"
    private_subnet_1_cidr_block = "10.0.3.0/24"
    private_subnet_1_availability_zone = "us-east-1a"
    private_subnet_2_cidr_block = "10.0.4.0/24"
    private_subnet_2_availability_zone = "us-east-1b"
}

module "eks_cluster" {
  source              = "./modules/terraform-eks-cluster"
  eks_cluster_name    = "agent-app-cluster"
  vpc_id              = module.vpc.vpc_id
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
}

module "irsa" {
  source = "./modules/terraform-irsa"
  eks_oidc_issuer = module.eks_cluster.eks_oidc_issuer
}

module "k8s_deployment" {
  source = "./modules/terraform-k8s-deployment"
  agent_alias_id = module.bedrock_agent_code.agent_alias_id
  agent_id = module.bedrock_agent_code.agent_id
  container_image_name = module.docker_build.container_image_name
  ecr_authorization_token = module.docker_build.ecr_authorization_token
  ecr_authorization_token_proxy_endpoint = module.docker_build.ecr_authorization_token_proxy_endpoint
  eks_certificate_authority_data = module.eks_cluster.eks_certificate_authority_data
  eks_cluster_name = module.eks_cluster.eks_cluster_name
  eks_endpoint = module.eks_cluster.eks_endpoint
  eks_irsa_role_arn = module.irsa.eks_irsa_role_arn
}

output "agent_alias_id" {
  value = module.bedrock_agent_code.agent_alias_id
}

output "agent_id" {
  value = module.bedrock_agent_code.agent_id
}

output "app_url" {
  value = "Send POST to http://${module.k8s_deployment.ingress_hostname}/api/code"
}
