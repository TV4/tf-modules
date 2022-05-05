# k8s-ocp-core

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | 0.5.1 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 4.13.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.13.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.4.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 3.1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_flux"></a> [flux](#module\_flux) | ../k8s-flux | n/a |
| <a name="module_flux_extras"></a> [flux\_extras](#module\_flux\_extras) | ../k8s-flux-extras | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_branch"></a> [branch](#input\_branch) | Git branch which to use for flux repo | `string` | `"master"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Name of cluster in the flux repo | `string` | n/a | yes |
| <a name="input_cluster_repo"></a> [cluster\_repo](#input\_cluster\_repo) | Name of flux repo | `string` | n/a | yes |
| <a name="input_cluster_resource"></a> [cluster\_resource](#input\_cluster\_resource) | Optional cluster resource to depend on | <pre>object({<br>    name = string<br>    arn  = string<br>  })</pre> | <pre>{<br>  "arn": "",<br>  "name": ""<br>}</pre> | no |
| <a name="input_extra_repos"></a> [extra\_repos](#input\_extra\_repos) | List of private github repos which should add the same deploy key. | `list(string)` | `[]` | no |
| <a name="input_flux_repo_path"></a> [flux\_repo\_path](#input\_flux\_repo\_path) | Default path to store clusters | `string` | `"clusters"` | no |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | Owner of flux repo, used in coalition with cluster\_repo to figure out github path | `string` | n/a | yes |
| <a name="input_helm_repository_istio"></a> [helm\_repository\_istio](#input\_helm\_repository\_istio) | URL for istio helm repo | `string` | `"https://istio-release.storage.googleapis.com/charts"` | no |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | Version of Istio, this will read the apropriate operator config within this repo | `string` | `"1.12.1"` | no |
| <a name="input_registry_flux"></a> [registry\_flux](#input\_registry\_flux) | Artifact registry to pull images from for flux | `string` | `"ghcr.io/fluxcd"` | no |
| <a name="input_registry_istio"></a> [registry\_istio](#input\_registry\_istio) | Artifact registry to pull images from for istio | `string` | `"gcr.io/istio-release"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->