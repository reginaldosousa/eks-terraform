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

locals {
  default_tags = {
    Project   = var.project_name
    Terraform = "true"
  }
}