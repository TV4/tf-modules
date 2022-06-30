variable "realm_id" {
  type = string
  description = "ID of the realm to operate within"
}

variable "groups" {
  type = list(string)
  description = "Names of groups to configure within Keycloak"
}

variable "github_oidc_client_id" {
  type = string
  description = "Github OIDC client id"
}

variable "github_oidc_client_secret" {
  type = string
  description = "Github OIDC client secret"
}

variable "k8s_clusters" {
  type = list(string)
  description = "Names of the kubernetes cluster for which to manage access"
}

variable "users" {
  type = map(object({
    github_username = string
    github_user_id  = string
    email           = string
    first_name      = string
    last_name       = string
    groups          = list(string)
  }))
  description = "Map of usernames and their properties to be configured"
}
