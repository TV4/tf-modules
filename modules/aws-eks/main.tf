terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.0"
    }
  }
}

# Create EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.20.0"

  cluster_version = var.eks_version
  cluster_name    = var.name
  vpc_id          = var.vpc
  subnets         = var.subnets
  node_groups     = var.node_groups
  map_roles       = var.roles
  map_users       = var.users
  map_accounts    = var.accounts
  enable_irsa     = true
  tags = {
    Terraform = "true"
    Name      = var.name
  }
}

# Kubernetes provider configuration
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "aws_eks_identity_provider_config" "keycloak" {
  for_each     = { for k, v in var.cluster_identity_providers : k => v if true }
  cluster_name = module.eks.cluster_id
  oidc {
    client_id                     = each.value.client_id
    groups_claim                  = lookup(each.value, "groups_claim", null)
    groups_prefix                 = lookup(each.value, "groups_prefix", null)
    identity_provider_config_name = try(each.value.identity_provider_config_name, each.key)
    issuer_url                    = each.value.issuer_url
    required_claims               = lookup(each.value, "required_claims", null)
    username_claim                = lookup(each.value, "username_claim", null)
    username_prefix               = lookup(each.value, "username_prefix", null)
  }
  tags = {
    Terrafom = "true"
    Name     = var.name
  }
}
