locals {
  # Definindo o CIDR para a VPC e as zonas de disponibilidade (AZs) a serem usadas
  vpc_cidr = "10.0.0.0/16"
  # Obtendo as primeiras 3 zonas de disponibilidade disponíveis na região especificada
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

# Configuração do módulo VPC para criar uma Virtual Private Cloud (VPC) na AWS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-vpc"
  cidr = local.vpc_cidr

  azs = local.azs
  # Gerando sub-redes privadas, públicas e intra para cada zona de disponibilidade usando 
  # a função cidrsubnet para calcular os CIDRs com base no CIDR da VPC
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  # Configurações para habilitar o NAT Gateway, que permite que as instâncias 
  # em sub-redes privadas acessem a internet, e para criar um único NAT Gateway para economizar custos
  enable_nat_gateway = true
  single_nat_gateway = true

  # Definindo tags para as sub-redes públicas e privadas, 
  # que são usadas pelo Kubernetes para identificar quais sub-redes 
  # devem ser usadas para os Load Balancers públicos e internos, respectivamente
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}