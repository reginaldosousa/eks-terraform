variable "project_name" {
  type        = string
  default     = "eks-terraform"
  description = "Nome do seu projeto"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Região da AWS onde os recursos serão criados"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Token de acesso do Cloudflare"
  sensitive   = true
}

variable "letsencrypt_email" {
  type        = string
  description = "Email utilizado para comunicação com a API Lets Encrypt"
}

locals {
  default_tags = {
    Project   = var.project_name
    Terraform = "true"
  }
}