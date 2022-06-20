resource "keycloak_realm" "realm" {
  realm   = var.realm_name
  enabled = true
}

resource "keycloak_openid_client" "client" {
  realm_id                     = keycloak_realm.realm.id
  client_id                    = "terraform-cli"
  name                         = "Terraform"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = false
  direct_access_grants_enabled = false
  service_accounts_enabled     = true
}

resource "keycloak_openid_client_service_account_role" "service_account_role_attachment" {
  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.client.service_account_user_id
  client_id               = data.keycloak_openid_client.realm_management.id
  role                    = data.keycloak_role.client_role.name
}

output "client_credentials" {
  value = {
    realm_id      = keycloak_realm.realm.id
    client_id     = keycloak_openid_client.client.client_id
    client_secret = keycloak_openid_client.client.client_secret
  }
  sensitive = true
}
