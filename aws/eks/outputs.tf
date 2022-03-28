output "kube_config" {
  description = "Kube config for the created EKS cluster"
  sensitive   = true
  value = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

output "cluster_autoscaler_config" {
  description = "Configuration for Cluster Autoscaler"
  value = {
    role_arn = module.cluster_autoscaler.role_arn
  }
}

output "cert_manager_config" {
  description = "Configuration for Cert Manager"
  value = {
    role_arn = module.cert_manager.role_arn
  }
}

output "external_dns_config" {
  description = "Configuration for External DNS"
  value = {
    role_arn = module.external_dns.role_arn
  }
}

output "loadbalancer_config" {
  description = "Configuration for Loadbalancer"
  value = {
    role_arn = module.loadbalancer.role_arn
  }
}

output "oidc_issuer_url" {
  value = data.aws_eks_cluster.cluster.cluster_oidc_issuer_url
}
