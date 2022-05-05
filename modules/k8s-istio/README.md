# k8s-istio

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.13.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.4.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.2.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1.13.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.4.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.base](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cni](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.eastwest](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.istiod](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.cni](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.istio_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.istio_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_resource"></a> [cluster\_resource](#input\_cluster\_resource) | Optional cluster resource to depend on | <pre>object({<br>    name = string<br>    arn  = string<br>  })</pre> | <pre>{<br>  "arn": "",<br>  "name": ""<br>}</pre> | no |
| <a name="input_enable_helmrelease_cni"></a> [enable\_helmrelease\_cni](#input\_enable\_helmrelease\_cni) | Whether to use cni helmrelease or not | `bool` | `true` | no |
| <a name="input_enable_predefined_cacerts"></a> [enable\_predefined\_cacerts](#input\_enable\_predefined\_cacerts) | Will read certificate files from folder structure if enabled, required for multicluster functionality | `bool` | `true` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | URL for helm repo | `string` | `"https://istio-release.storage.googleapis.com/charts"` | no |
| <a name="input_hub"></a> [hub](#input\_hub) | Artifact registry to pull images from for istio | `string` | `"gcr.io/istio-release"` | no |
| <a name="input_ingress_affinity"></a> [ingress\_affinity](#input\_ingress\_affinity) | Affinity of Istio Ingress | `any` | <pre>{<br>  "nodeAffinity": {<br>    "requiredDuringSchedulingIgnoredDuringExecution": {<br>      "nodeSelectorTerms": [<br>        {<br>          "matchExpressions": [<br>            {<br>              "key": "node-role.tvm.telia.com/ingress",<br>              "operator": "Exists"<br>            }<br>          ]<br>        }<br>      ]<br>    }<br>  }<br>}</pre> | no |
| <a name="input_ingress_autoscaling"></a> [ingress\_autoscaling](#input\_ingress\_autoscaling) | Number of ingresses running | `any` | <pre>{<br>  "enabled": true,<br>  "maxReplicas": 9,<br>  "minReplicas": 3,<br>  "targetCPUUtilizationPercentage": 60<br>}</pre> | no |
| <a name="input_ingress_service_annotations"></a> [ingress\_service\_annotations](#input\_ingress\_service\_annotations) | Service annotations for ingress services, required for AWS loadbalancer etc | `any` | <pre>{<br>  "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "instance",<br>  "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing",<br>  "service.beta.kubernetes.io/aws-load-balancer-type": "external"<br>}</pre> | no |
| <a name="input_ingress_service_ports"></a> [ingress\_service\_ports](#input\_ingress\_service\_ports) | Ingress ports, leave default unless using nodeport in service type | `any` | <pre>[<br>  {<br>    "name": "status-port",<br>    "port": 15021,<br>    "protocol": "TCP",<br>    "targetPort": 15021<br>  },<br>  {<br>    "name": "http2",<br>    "port": 80,<br>    "protocol": "TCP",<br>    "targetPort": 8080<br>  },<br>  {<br>    "name": "https",<br>    "port": 443,<br>    "protocol": "TCP",<br>    "targetPort": 8443<br>  }<br>]</pre> | no |
| <a name="input_ingress_service_type"></a> [ingress\_service\_type](#input\_ingress\_service\_type) | Service type, such as LoadBalancer or NodePort | `string` | `"LoadBalancer"` | no |
| <a name="input_ingress_tolerations"></a> [ingress\_tolerations](#input\_ingress\_tolerations) | Tolerations of Istio Ingress | `list(any)` | <pre>[<br>  {<br>    "effect": "NoSchedule",<br>    "key": "ingress-node",<br>    "operator": "Exists"<br>  }<br>]</pre> | no |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | Version of Istio, this will read the apropriate operator config within this repo | `string` | `"1.12.1"` | no |
| <a name="input_meshID"></a> [meshID](#input\_meshID) | Name of mesh for multi-cluster | `string` | `"tvm"` | no |
| <a name="input_multi_cluster"></a> [multi\_cluster](#input\_multi\_cluster) | Multi-cluster functionality | `any` | <pre>{<br>  "clusterName": "",<br>  "enabled": false<br>}</pre> | no |
| <a name="input_network"></a> [network](#input\_network) | Name of network, for multicluster communication (just a string identifier) | `string` | `"aws"` | no |
| <a name="input_proxy_resources"></a> [proxy\_resources](#input\_proxy\_resources) | Resources for sidecar proxy | `any` | <pre>{<br>  "limits": {<br>    "cpu": "2000m",<br>    "memory": "4096Mi"<br>  },<br>  "requests": {<br>    "cpu": "100m",<br>    "memory": "128Mi"<br>  }<br>}</pre> | no |
| <a name="input_zipkin"></a> [zipkin](#input\_zipkin) | Jaeger and Zipkin url | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->