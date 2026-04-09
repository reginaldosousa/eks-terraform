# Configuração do Terraform para criar recursos na AWS
terraform {
  required_version = "~> 1.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
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

# Pega a configuração de autenticação do cluster EKS criado pelo módulo eks,
# que inclui o token de autenticação necessário para se conectar ao cluster EKS.
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Configuração do provedor Helm para gerenciar pacotes Helm no cluster EKS.
provider "helm" {
  kubernetes = {
    # Configurações para se conectar ao cluster EKS usando o endpoint do cluster,
    # o certificado de autoridade do cluster e um token de autenticação.
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Configuração do provedor Kubernetes para gerenciar recursos Kubernetes no cluster EKS.
provider "kubernetes" {
  # Configurações para se conectar ao cluster EKS usando o endpoint do cluster,
  # o certificado de autoridade do cluster e um token de autenticação.
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

