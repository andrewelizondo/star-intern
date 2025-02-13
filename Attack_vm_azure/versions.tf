terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    azurerm = {
      version = " ~> 3.108"
      source  = "hashicorp/azurerm"
    }
  }
}