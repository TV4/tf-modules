locals {
  known_hosts = <<-EOT
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
EOT
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
    labels = {
      name = "flux-system"
    }
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
  depends_on = [var.cluster_resource]
}

data "github_repository" "cluster" {
  full_name = "${var.github_owner}/${var.cluster_repo}"
}

resource "tls_private_key" "cluster" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "flux_install" "this" {
  target_path = "${var.flux_repo_path}/${var.cluster_id}"
  registry    = var.registry_flux
}

data "flux_sync" "this" {
  url         = "ssh://git@github.com/${var.github_owner}/${var.cluster_repo}.git"
  target_path = "${var.flux_repo_path}/${var.cluster_id}"
  branch      = var.branch
  interval    = 1
}

resource "github_repository_deploy_key" "cluster" {
  title      = "flux-${var.cluster_id}"
  repository = data.github_repository.cluster.name
  key        = tls_private_key.cluster.public_key_openssh
  read_only  = true
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

resource "github_repository_file" "install" {
  repository          = data.github_repository.cluster.name
  branch              = var.branch
  file                = data.flux_install.this.path
  content             = data.flux_install.this.content
  overwrite_on_create = true
}

resource "github_repository_file" "sync" {
  repository          = data.github_repository.cluster.name
  branch              = var.branch
  file                = data.flux_sync.this.path
  content             = data.flux_sync.this.content
  overwrite_on_create = true
}

resource "github_repository_file" "kustomize" {
  repository          = data.github_repository.cluster.name
  branch              = var.branch
  file                = data.flux_sync.this.kustomize_path
  content             = file("${path.module}/templates/kustomization-override.yaml")
  overwrite_on_create = true
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.this.content
}

resource "kubectl_manifest" "install" {
  for_each   = data.kubectl_file_documents.install.manifests
  depends_on = [kubernetes_namespace.flux_system]

  # It will sort itself out eventually (deployment will fail on OCP due to patch cant be applied at first start)
  wait_for_rollout = false

  yaml_body = each.value
  lifecycle {
    prevent_destroy = true
  }
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.this.content
}

resource "kubectl_manifest" "sync" {
  for_each   = data.kubectl_file_documents.sync.manifests
  depends_on = [kubectl_manifest.install, kubernetes_namespace.flux_system]

  yaml_body = each.value
  lifecycle {
    prevent_destroy = true
  }
}

resource "kubernetes_secret" "cluster" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.this.name
    namespace = data.flux_sync.this.namespace
  }

  data = {
    identity       = tls_private_key.cluster.private_key_pem
    "identity.pub" = tls_private_key.cluster.public_key_pem
    known_hosts    = local.known_hosts
  }
}

resource "kubernetes_secret" "extras" {
  for_each   = toset(var.extra_repos)
  depends_on = [kubernetes_namespace.flux_system]

  metadata {
    name      = each.key
    namespace = data.flux_sync.this.namespace
  }

  data = {
    identity       = tls_private_key.extras[each.key].private_key_pem
    "identity.pub" = tls_private_key.extras[each.key].public_key_pem
    known_hosts    = local.known_hosts
  }
}

