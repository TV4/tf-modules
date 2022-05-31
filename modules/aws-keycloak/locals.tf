locals {
  mysql_bootstrap_image = "public.ecr.aws/ubuntu/mysql:latest"
  keycloak_image  = "jboss/keycloak:12.0.4"
  default_tags = merge(var.tags, {"Application" = "Keycloak"})
}
