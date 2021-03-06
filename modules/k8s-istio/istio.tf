resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      name                        = "istio-system"
      "topology.istio.io/network" = var.network
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

resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name = "istio-ingress"
    labels = {
      name                            = "istio-ingress"
      istio-injection                 = "enabled"
      "istio.k8s-infra.tvm/namespace" = "true"
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

resource "kubectl_manifest" "cni" {
  count      = var.enable_helmrelease_cni ? 1 : 0
  depends_on = [kubernetes_namespace.istio_ingress]
  yaml_body  = <<YAML
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: istio-cni
  namespace: istio-ingress
YAML
}
#resource "kubernetes_secret" "this" {
#  count = var.enable_predefined_cacerts ? 1 : 0
#  metadata {
#    name      = "cacerts"
#    namespace = kubernetes_namespace.istio_system.id
#  }
#  data = {
#    "ca-cert.pem"    = file("certs/ca-cert.pem")
#    "ca-key.pem"     = file("certs/ca-key.pem")
#    "root-cert.pem"  = file("certs/root-cert.pem")
#    "cert-chain.pem" = file("certs/cert-chain.pem")
#  }
#}

resource "helm_release" "base" {
  name       = "istio-base"
  namespace  = "istio-system"
  depends_on = [kubernetes_namespace.istio_system]
  repository = var.helm_repository
  chart      = "base"
  version    = var.istio_version
}

# FIXME: OPENSHIFT ONLY!?
resource "helm_release" "cni" {
  count      = var.enable_helmrelease_cni ? 1 : 0
  name       = "istio-cni"
  namespace  = "kube-system"
  depends_on = [helm_release.base]
  repository = var.helm_repository
  chart      = "cni"
  version    = var.istio_version
  #wait       = false
  set {
    name  = "global.hub"
    value = var.hub
  }
  set {
    name  = "cni.cniBinDir"
    value = "/var/lib/cni/bin"
  }
  set {
    name  = "cni.cniConfDir"
    value = "/etc/cni/multus/net.d"
  }
  set {
    name  = "cni.cniConfFileName"
    value = "istio-cni.conf"
  }
  set {
    name  = "cni.chained"
    value = "false"
  }
  set {
    name  = "cni.repair.enabled"
    value = "false"
  }
  set {
    name  = "cni.logLevel"
    value = "info"
  }
  postrender {
    binary_path = "${path.module}/patch-ocp-cni.sh"
  }

}

resource "helm_release" "istiod_cni" {
  count      = var.enable_helmrelease_cni ? 1 : 0
  name       = "istiod"
  namespace  = "istio-system"
  depends_on = [helm_release.cni]
  repository = var.helm_repository
  chart      = "istiod"
  version    = var.istio_version

  set {
    name  = "global.hub"
    value = var.hub
  }
  set {
    name  = "global.proxy.holdApplicationUntilProxyStarts"
    value = true
  }
  set {
    name  = "global.proxy.resources.requests.cpu"
    value = var.proxy_resources.requests.cpu
  }
  set {
    name  = "global.proxy.resources.requests.memory"
    value = var.proxy_resources.requests.memory
  }
  set {
    name  = "global.proxy.resources.limits.cpu"
    value = var.proxy_resources.limits.cpu
  }
  set {
    name  = "global.proxy.resources.limits.memory"
    value = var.proxy_resources.limits.memory
  }
  set {
    name  = "istio_cni.enabled"
    value = "true"
  }
  set {
    name  = "sidecarInjectorWebhook.injectedAnnotations.k8s\\.v1\\.cni\\.cncf\\.io/networks"
    value = "istio-cni"
  }
  set {
    name  = "global.multiCluster.enabled"
    value = var.multi_cluster.enabled
  }
  set {
    name  = "global.multiCluster.clusterName"
    value = var.multi_cluster.clusterName
  }
  set {
    name  = "global.meshID"
    value = var.meshID
  }
  set {
    name  = "global.network"
    value = var.network
  }
  set {
    name  = "global.tracer.zipkin.address"
    value = var.zipkin
  }
  set {
    name  = "pilot.autoscaleMin"
    value = 2
  }
}

resource "helm_release" "istiod" {
  count      = var.enable_helmrelease_cni ? 0 : 1
  name       = "istiod"
  namespace  = "istio-system"
  depends_on = [helm_release.base]
  repository = var.helm_repository
  chart      = "istiod"
  version    = var.istio_version

  set {
    name  = "global.hub"
    value = var.hub
  }
  set {
    name  = "global.proxy.holdApplicationUntilProxyStarts"
    value = true
  }
  set {
    name  = "global.proxy.resources.requests.cpu"
    value = var.proxy_resources.requests.cpu
  }
  set {
    name  = "global.proxy.resources.requests.memory"
    value = var.proxy_resources.requests.memory
  }
  set {
    name  = "global.proxy.resources.limits.cpu"
    value = var.proxy_resources.limits.cpu
  }
  set {
    name  = "global.proxy.resources.limits.memory"
    value = var.proxy_resources.limits.memory
  }
  set {
    name  = "global.multiCluster.enabled"
    value = var.multi_cluster.enabled
  }
  set {
    name  = "global.multiCluster.clusterName"
    value = var.multi_cluster.clusterName
  }
  set {
    name  = "global.meshID"
    value = var.meshID
  }
  set {
    name  = "global.network"
    value = var.network
  }
  set {
    name  = "global.tracer.zipkin.address"
    value = var.zipkin
  }
  set {
    name  = "pilot.autoscaleMin"
    value = 2
  }
}

resource "helm_release" "ingress" {
  name       = "istio-ingress"
  namespace  = "istio-ingress"
  depends_on = [helm_release.istiod, helm_release.istiod_cni, kubernetes_namespace.istio_ingress]
  repository = var.helm_repository
  chart      = "gateway"
  version    = var.istio_version
  values = [templatefile("${path.module}/templates/ingress.yaml",
    {
      v_autoscaling = var.ingress_autoscaling,
      v_tolerations = var.ingress_tolerations,
      v_affinity    = var.ingress_affinity,
      v_annotations = var.ingress_service_annotations
      v_ports       = var.ingress_service_ports
      v_type        = var.ingress_service_type
    }
  )]
}

resource "helm_release" "eastwest" {
  count      = var.enable_predefined_cacerts ? 1 : 0
  name       = "istio-eastwestgateway"
  namespace  = "istio-ingress"
  depends_on = [helm_release.istiod, kubernetes_namespace.istio_ingress]
  repository = var.helm_repository
  chart      = "gateway"
  version    = var.istio_version
  values = [templatefile("${path.module}/templates/eastwest.yaml",
    {
      v_network     = var.network,
      v_autoscaling = var.ingress_autoscaling,
      v_tolerations = var.ingress_tolerations,
      v_affinity    = var.ingress_affinity,
      v_annotations = var.ingress_service_annotations
    }
  )]
}
# TBD: add egress gateway helm install, utilizing ClusterIP for service.
