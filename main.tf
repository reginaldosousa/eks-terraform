terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "zones" {
  region = "us-east-1"
}

output "availability_zones" {
  value = data.aws_availability_zones.zones.names
}