//Declare Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

//Declare Provider Block
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "CloudIdentityFortress"
      Environment = "Security-Enterprise"
    }
  }
}
