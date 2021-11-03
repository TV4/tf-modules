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
