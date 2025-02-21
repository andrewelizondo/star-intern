variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "eks-vpc"
}

variable vpc_cidr_block {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable public_subnet_1_cidr_block {
  description = "CIDR block for the 1st public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable public_subnet_1_availability_zone {
  description = "Availability zone for the 1st public subnet"
  type        = string
  default     = "us-east-1a"
}

variable public_subnet_2_cidr_block {
  description = "CIDR block for the 2nd public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable public_subnet_2_availability_zone {
  description = "Availability zone for the 2nd public subnet"
  type        = string
  default     = "us-east-1b"
}

variable private_subnet_1_cidr_block {
  description = "CIDR block for the 1st private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable private_subnet_1_availability_zone {
  description = "Availability zone for the 1st private subnet"
  type        = string
  default     = "us-east-1a"
}

variable private_subnet_2_cidr_block {
  description = "CIDR block for the 2nd private subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable private_subnet_2_availability_zone {
  description = "Availability zone for the 2nd private subnet"
  type        = string
  default     = "us-east-1b"
}