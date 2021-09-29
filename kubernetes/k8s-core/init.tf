variable "branch" {}
variable "cluster_id" {}
variable "cluster_repo" {}
variable "environment" {}
variable "github_owner" {}
variable "istio_version" {}
variable "istio_control_plane_yaml" {}
variable "istio_gateways_yaml" {}

provider "github" {
  owner = var.github_owner
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
      version = "0.3.1"
    }
    github = {
      source  = "integrations/github"
      version = "4.13.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.3"
    }
  }
}

