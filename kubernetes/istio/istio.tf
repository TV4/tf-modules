resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      name                        = "istio-system"
      "topology.istio.io/network" = var.network
    }
  }
  lifecycle {
    #prevent_destroy = true
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
    #prevent_destroy = true
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
  depends_on = [var.cluster_resource]
}

resource "helm_release" "base" {
  name       = "istio-base"
  namespace  = "istio-system"
  depends_on = [kubernetes_namespace.istio_system]
  repository = var.helm_repository
  chart      = "base"
  version    = var.istio_version
}

resource "helm_release" "istiod" {
  name      = "istiod"
  namespace = "istio-system"
  # depends_on = [helm_release.cni]
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
}

resource "helm_release" "ingress" {
  name       = "istio-ingress"
  namespace  = "istio-ingress"
  depends_on = [helm_release.istiod, kubernetes_namespace.istio_ingress]
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
