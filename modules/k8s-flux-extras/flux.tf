locals {
  known_hosts = <<-EOT
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
EOT
}

resource "tls_private_key" "extras" {
  for_each    = toset(var.extra_repos)
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

data "github_repository" "extras" {
  for_each  = toset(var.extra_repos)
  full_name = "${var.github_owner}/${each.key}"
}

resource "github_repository_deploy_key" "extras" {
  for_each   = toset(var.extra_repos)
  title      = "flux-${var.cluster_id}"
  repository = data.github_repository.extras[each.key].name
  key        = tls_private_key.extras[each.key].public_key_openssh
  read_only  = true
}

# FIXME: Add proper depends_on
resource "kubernetes_secret" "extras" {
  for_each = toset(var.extra_repos)

  metadata {
    name      = each.key
    namespace = "flux-system"
  }

  data = {
    identity       = tls_private_key.extras[each.key].private_key_pem
    "identity.pub" = tls_private_key.extras[each.key].public_key_pem
    known_hosts    = local.known_hosts
  }
}

