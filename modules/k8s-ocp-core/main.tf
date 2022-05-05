terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "3.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.5.1"
    }
    github = {
      source  = "integrations/github"
      version = "4.13.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.0"
    }
  }
}

module "flux" {
  source         = "../k8s-flux"
  branch         = var.branch
  cluster_id     = var.cluster_id
  cluster_repo   = var.cluster_repo
  flux_repo_path = var.flux_repo_path
  github_owner   = var.github_owner
  registry_flux  = var.registry_flux
}

module "flux_extras" {
  source       = "../k8s-flux-extras"
  branch       = var.branch
  cluster_id   = var.cluster_id
  cluster_repo = var.cluster_repo
  github_owner = var.github_owner
  extra_repos  = var.extra_repos
}

#module "istio" {
#  source = "../istio"
#
#  # On prem, so special registry required
#  network         = "ddc"
#  hub             = var.registry_istio
#  istio_version   = var.istio_version
#  helm_repository = var.helm_repository_istio
#
#  # On prem, so no annotations for AWS LB.
#  ingress_service_annotations = {}
#
#  # No dedicated nodes
#  ingress_tolerations = []
#  ingress_affinity    = {}
#
#  # No multicluster in OCP ... yet
#  enable_predefined_cacerts = false
#  multi_cluster = {
#    enabled     = false
#    clusterName = ""
#  }
#}
