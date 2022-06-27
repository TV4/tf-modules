resource "keycloak_oidc_identity_provider" "github" {
  realm             = var.realm_id
  alias             = "github"
  authorization_url = "https://github.com/login/oauth/authorize"
  client_id         = var.github_oidc_client_id
  client_secret     = var.github_oidc_client_secret
  token_url         = "https://github.com/login/oauth/access_token"
  user_info_url     = "https://api.github.com/user"

  extra_config = {
    "clientAuthMethod" = "client_secret_basic"
  }
}
