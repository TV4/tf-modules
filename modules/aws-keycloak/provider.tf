terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "test"
}
