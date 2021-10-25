provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "github" {
  owner = var.github_owner
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
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

