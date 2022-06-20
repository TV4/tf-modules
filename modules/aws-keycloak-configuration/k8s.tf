resource "keycloak_openid_client" "k8s_clusters" {
  for_each                                  = toset(var.k8s_clusters)
  realm_id                                  = var.realm_id
  client_id                                 = each.value
  access_type                               = "CONFIDENTIAL"
  standard_flow_enabled                     = true
  implicit_flow_enabled                     = false
  direct_access_grants_enabled              = true
  service_accounts_enabled                  = true
  oauth2_device_authorization_grant_enabled = true
  backchannel_logout_session_required       = true

  root_url    = "http://localhost:8000/"
  base_url    = "http://localhost:8000/"
  admin_url   = "http://localhost:8000/"
  web_origins = ["*"]

  valid_redirect_uris = [
    "http://localhost:8000/*"
  ]
}

resource "keycloak_openid_client_scope" "k8s_clusters" {
  realm_id               = var.realm_id
  name                   = "groups"
  description            = "When requested, this scope will map a user's group memberships to a claim"
  include_in_token_scope = true
  consent_screen_text    = false
}

resource "keycloak_openid_client_default_scopes" "k8s_clusters" {
  for_each  = toset(var.k8s_clusters)
  realm_id  = var.realm_id
  client_id = keycloak_openid_client.k8s_clusters[each.value].id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.k8s_clusters.name,
  ]
}

resource "keycloak_openid_group_membership_protocol_mapper" "k8s_clusters" {
  for_each            = toset(var.k8s_clusters)
  realm_id            = var.realm_id
  client_scope_id     = keycloak_openid_client_scope.k8s_clusters.id
  name                = "k8s-group-membership-mapper"
  add_to_id_token     = true
  add_to_access_token = true
  add_to_userinfo     = true
  full_path           = false

  claim_name = "groups"
}