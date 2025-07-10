terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      "Project"     = "Nodejs SimpleAPI with DB"
      "Environment" = "Development"
      "CreatedBy"   = "Terraform"
      "ManagedBy"   = "Gabriel Ibenye"
    }
  }
}