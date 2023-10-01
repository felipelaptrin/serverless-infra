terraform {
  required_version = "~> 1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17.0"
    }
  }

  backend "s3" {
    bucket = "terraform-states-flat"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Name  = "CreatedBy"
      Owner = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"

  default_tags {
    tags = {
      Name  = "CreatedBy"
      Owner = "Terraform"
    }
  }
}
