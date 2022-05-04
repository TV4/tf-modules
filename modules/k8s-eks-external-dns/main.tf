terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2.0"
    }
  }
}

module "oidc" {
  source    = "../k8s-eks-oidc-service-account"
  role_arn  = var.role_arn
  name      = "external-dns"
  namespace = "external-dns"
}



resource "helm_release" "this" {
  name       = "external-dns"
  namespace  = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  depends_on = [module.oidc]

  set {
    name  = "provider"
    value = "aws"
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
    value = "service"
  }
  set {
    name  = "sources[1]"
    value = "ingress"
  }
  set {
    name  = "sources[2]"
    value = "istio-gateway"
  }
  set {
    name  = "sources[3]"
    value = "istio-virtualservice"
  }
}
