resource "random_id" "random" {
  byte_length = 8
}

locals {
  mysql_bootstrap_image = "public.ecr.aws/ubuntu/mysql:latest"
  keycloak_image        = "quay.io/keycloak/keycloak:18.0.1"
  default_tags          = merge(var.tags, { "Application" = "Keycloak", "Keycloak" = local.kc_id })
  keycloak_command      = "[${join(", ", formatlist("\"%s\"", concat(var.keycloak_verbose_logging ? ["--verbose"] : [], ["start", "--auto-build", "--hostname", var.keycloak_url])))}]"
  kc_id                 = lower(random_id.random.id)
  rds_master_username   = "admin"
  rds_database_name     = "keycloak"
}
