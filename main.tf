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
  region = "us-east-1"
}

# Recupera as zonas de disponibilidade disponíveis na região especificada 
# apenas para validar a configuração do provedor e garantir que a região 
# está correta. Isso é útil para evitar erros de configuração e garantir 
# que os recursos sejam criados na região desejada.
data "aws_availability_zones" "zones" {
  region = "us-east-1"
}

# Exibe as zonas de disponibilidade recuperadas para verificar se a configuração
# do provedor está correta e se as zonas estão disponíveis na região especificada.
output "availability_zones" {
  value = data.aws_availability_zones.zones.names
}