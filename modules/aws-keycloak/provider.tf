terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.74.0, < 4.0.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "test"
}
