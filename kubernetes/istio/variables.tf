variable "cluster_resource" {
  description = "Optional cluster resource to depend on"
  type = object({
    name = string
    arn  = string
  })
  default = {
    name = ""
    arn  = ""
  }
}

variable "hub" {
  description = "Artifact registry to pull images from for istio"
  type        = string
  default     = "gcr.io/istio-release"
}

variable "istio_version" {
  description = "Version of Istio, this will read the apropriate operator config within this repo"
  type        = string
  default     = "1.12.2"
}

variable "ingress_autoscaling" {
  description = "Number of ingresses running"
  type        = any
  default = {
    enabled                        = true
    minReplicas                    = 3
    maxReplicas                    = 9
    targetCPUUtilizationPercentage = 60
  }
}

variable "ingress_tolerations" {
  description = "Tolerations of Istio Ingress"
  type        = list(any)
  default = [
    { effect = "NoSchedule", key = "ingress-node", operator = "Exists" }
  ]
}

variable "ingress_affinity" {
  description = "Affinity of Istio Ingress"
  type        = any
  default = {
    nodeAffinity = {
      requiredDuringSchedulingIgnoredDuringExecution = {
        nodeSelectorTerms = [
          { matchExpressions = [{ key = "node-role.tvm.telia.com/ingress", operator = "Exists" }] }
        ]
      }
    }
  }
}

variable "ingress_service_annotations" {
  description = "Service annotations for ingress services, required for AWS loadbalancer etc"
  type        = any
  default = {
    "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
    "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "instance"
    "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
  }
}

variable "ingress_service_ports" {
  description = "Ingress ports, leave default unless using nodeport in service type"
  type        = any
  default = [
    { port = 15021, targetPort = 15021, name = "status-port", protocol = "TCP" },
    { port = 80, targetPort = 8080, name = "http2", protocol = "TCP" },
    { port = 443, targetPort = 8443, name = "https", protocol = "TCP" }
  ]
}

variable "ingress_service_type" {
  description = "Service type, such as LoadBalancer or NodePort"
  type        = string
  default     = "LoadBalancer"
}

variable "multi_cluster" {
  description = "Multi-cluster functionality"
  type        = any
  default = {
    enabled     = false
    clusterName = ""
  }
}

variable "network" {
  description = "Name of network, for multicluster communication (just a string identifier)"
  type        = string
  default     = "aws"
}

variable "meshID" {
  description = "Name of mesh for multi-cluster"
  type        = string
  default     = "tvm"
}

variable "proxy_resources" {
  description = "Resources for sidecar proxy"
  type        = any
  default = {
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
    limits = {
      cpu    = "2000m"
      memory = "4096Mi"
    }
  }
}

variable "enable_predefined_cacerts" {
  description = "Will read certificate files from folder structure if enabled, required for multicluster functionality"
  type        = bool
  default     = true
}

variable "helm_repository" {
  description = "URL for helm repo"
  type        = string
  default     = "https://istio-release.storage.googleapis.com/charts"
}
