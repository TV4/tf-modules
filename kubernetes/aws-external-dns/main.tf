terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2.0"
    }
  }
}

module "oidc" {
  source    = "../aws-oidc-service-account"
  role_arn  = var.role_arn
  name      = "external-dns"
  namespace = "external-dns"
}

resource "helm_release" "this" {
  name       = "external-dns"
  namespace  = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  depends_on = [module.oidc]

  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "aws.region"
    value = var.region
  }
  set {
    name  = "aws.zoneType"
    value = var.zone_type
  }
  # This sets a restriction on that we can only have one EKS cluster with this name in each zone.
  set {
    name  = "txtOwnerId"
    value = var.name
  }
  set {
    name  = "domainFilters[0]"
    value = var.zone_name
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }
  set {
    name  = "sources[0]"
    value = var.sources
  }
}
