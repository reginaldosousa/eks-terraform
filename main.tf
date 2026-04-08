# Configuração do Terraform para criar recursos na AWS
terraform {
  required_version = "~> 1.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }
  backend "s3" {
    bucket = "eks-terraform-state-20260408"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Declara o provedor AWS e a região onde os recursos serão criados
provider "aws" {
  region = var.region

  default_tags {
    tags = local.default_tags
  }
}
