
provider "kubernetes" {
  config_path = "~/.kube/config"
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
  }
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
  depends_on = [var.cluster_resource]
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.external_dns_config.role_arn
    }
  }
}

# Install external-dns through flux ... or with this command :)
#helm install external-dns stable/external-dns \
#--set domainFilters[0]=<DOMAIN_FILTER>\
#--set txtOwnerId=<HOSTED_ZONE_ID> \
#--set serviceAccount.create=false
#--set serviceAccount.name="external-dns"
