resource "kubernetes_namespace" "istio_operator" {
  metadata {
    name = "istio-operator"
    labels = {
      name = "istio-operator"
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
  depends_on = [var.cluster_resource]
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      name = "istio-system"
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
  depends_on = [var.cluster_resource]
}

# For when Istio helm chart is packed properly:
# repository = "docker.io/istio"
# chart = "istio-operator"
# version = "1.11.2"

# get charts dir (run from projects root-dir):
# export VERSION=1.11.2; mkdir -p charts/istio/${VERSION}; cd charts/istio/${VERSION}; curl -L "https://github.com/istio/istio/releases/download/${VERSION}/istio-${VERSION}-linux-amd64.tar.gz" | tar xz --wildcards "*/manifests/charts/istio-operator" --strip-components=3
resource "helm_release" "istio_operator" {
  name       = "istio-operator"
  namespace  = "istio-operator"
  depends_on = [kubernetes_namespace.istio_operator]
  chart      = "${path.module}/charts/istio/${var.istio_version}/istio-operator"
  set {
    name  = "operatorNamespace"
    value = "istio-operator"
  }
  set {
    name  = "watchedNamespaces"
    value = "istio-system"
  }
  set {
    name  = "hub"
    value = var.registry_istio
  }
}

# Reason for keeping control plane and gateways separate: https://istio.io/latest/docs/setup/upgrade/gateways/ 
# But in essence: Update control plane first and verify, then after that's done update the gateways. So updating 
# istio should always be done during 2 reconciliations.
resource "kubectl_manifest" "istio_control_plane" {
  depends_on = [kubernetes_namespace.istio_system, helm_release.istio_operator]
  yaml_body  = var.istio_control_plane_yaml
}

resource "kubectl_manifest" "istio_gateways" {
  depends_on = [kubectl_manifest.istio_control_plane]
  yaml_body  = var.istio_gateways_yaml
}
