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
    ignore_changes = [
      metadata[0].labels,
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
  target_path = "clusters/${var.cluster_id}"
  registry    = var.registry_flux
}

data "flux_sync" "this" {
  url         = "ssh://git@github.com/${var.github_owner}/${var.cluster_repo}.git"
  target_path = "clusters/${var.cluster_id}"
  branch      = var.branch
  interval    = 1
}

resource "github_repository_deploy_key" "cluster" {
  title      = "flux-${var.cluster_id}"
  repository = data.github_repository.cluster.name
  key        = tls_private_key.cluster.public_key_openssh
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
  content             = data.flux_sync.this.kustomize_content
  overwrite_on_create = true
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.this.content
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in data.kubectl_file_documents.install.documents : sha1(v) => v }
  depends_on = [kubernetes_namespace.flux_system]

  yaml_body = each.value
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.this.content
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in data.kubectl_file_documents.sync.documents : sha1(v) => v }
  depends_on = [kubectl_manifest.install, kubernetes_namespace.flux_system]

  yaml_body = each.value
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

