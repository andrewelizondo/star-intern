variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = ""
}

variable "private_subnet_1_id" {
  description = "ID of the first private subnet"
  type        = string
  default     = ""
}

variable "private_subnet_2_id" {
  description = "ID of the second private subnet"
  type        = string
  default     = ""
}

 variable "eks_cluster_name" {
   description = "EKS cluster name"
   type        = string
   default     = "eks-cluster"
 }