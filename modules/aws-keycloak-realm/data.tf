data "keycloak_openid_client" "realm_management" {
  realm_id  = keycloak_realm.realm.id
  client_id = "realm-management"
}

data "keycloak_role" "client_role" {
  realm_id    = keycloak_realm.realm.id
  client_id   = data.keycloak_openid_client.realm_management.id
  name        = "realm-admin"
}