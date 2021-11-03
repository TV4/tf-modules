locals {
  known_hosts = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
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
  for_each  = toset(var.extra_repos)
  algorithm = "RSA"
  rsa_bits  = 4096
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

