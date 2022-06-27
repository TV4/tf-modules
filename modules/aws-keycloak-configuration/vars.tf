variable "realm_id" {
  type = string
}

variable "groups" {
  type = list(string)
}

variable "github_oidc_client_id" {
  type = string
}

variable "github_oidc_client_secret" {
  type = string
}

variable "k8s_clusters" {
  type = list(string)
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
}
