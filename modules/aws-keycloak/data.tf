data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {
}

data "aws_iam_policy" "amazon_ec2_container_registry_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_kms_key" "secretsmanager" {
  key_id = "alias/${var.secrets_manager_kms_key_alias}"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}
