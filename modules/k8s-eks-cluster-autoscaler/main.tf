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
  name      = "cluster-autoscaler"
  namespace = "cluster-autoscaler"
}

resource "helm_release" "this" {
  name       = "cluster-autoscaler"
  namespace  = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  depends_on = [module.oidc]

  set {
    name  = "autoDiscovery.clusterName"
    value = var.name
  }
  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "cloudProvider"
    value = "aws"
  }
  set {
    name  = "rbac.serviceAccount.create"
    value = false
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
}
