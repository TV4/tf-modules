terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4.1"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.5.1"
    }
    github = {
      source  = "integrations/github"
      version = "4.25.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

