resource "keycloak_group" "local_group" {
  for_each = toset(var.groups)
  realm_id = var.realm_id
  name     = each.value
}

resource "keycloak_user" "local_user" {
  for_each   = var.users
  realm_id   = var.realm_id
  username   = each.key
  email      = each.value.email
  first_name = each.value.first_name
  last_name  = each.value.last_name
  federated_identity {
    identity_provider = keycloak_oidc_identity_provider.github.alias
    user_id           = each.value.github_user_id
    user_name         = each.value.github_username
  }
}

resource "keycloak_user_groups" "user_groups" {
  for_each = var.users
  realm_id = var.realm_id
  user_id  = keycloak_user.local_user[each.key].id

  group_ids = [
    for group in each.value.groups : keycloak_group.local_group[group].id
  ]
}
