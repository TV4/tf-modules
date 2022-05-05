# k8s-core

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

| Name | Version |
|------|---------|
| <a name="provider_flux"></a> [flux](#provider\_flux) | 0.5.1 |
| <a name="provider_github"></a> [github](#provider\_github) | 4.13.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.2.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.13.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.4.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_repository_deploy_key.cluster](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/resources/repository_deploy_key) | resource |
| [github_repository_deploy_key.extras](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/resources/repository_deploy_key) | resource |
| [github_repository_file.install](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/resources/repository_file) | resource |
| [github_repository_file.kustomize](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/resources/repository_file) | resource |
| [github_repository_file.sync](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/resources/repository_file) | resource |
| [helm_release.istio_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.install](https://registry.terraform.io/providers/gavinbunney/kubectl/1.13.0/docs/resources/manifest) | resource |
| [kubectl_manifest.istio_control_plane](https://registry.terraform.io/providers/gavinbunney/kubectl/1.13.0/docs/resources/manifest) | resource |
| [kubectl_manifest.istio_gateways](https://registry.terraform.io/providers/gavinbunney/kubectl/1.13.0/docs/resources/manifest) | resource |
| [kubectl_manifest.sync](https://registry.terraform.io/providers/gavinbunney/kubectl/1.13.0/docs/resources/manifest) | resource |
| [kubernetes_namespace.flux_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.istio_operator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.istio_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.extras](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [tls_private_key.cluster](https://registry.terraform.io/providers/hashicorp/tls/3.1.0/docs/resources/private_key) | resource |
| [tls_private_key.extras](https://registry.terraform.io/providers/hashicorp/tls/3.1.0/docs/resources/private_key) | resource |
| [flux_install.this](https://registry.terraform.io/providers/fluxcd/flux/0.5.1/docs/data-sources/install) | data source |
| [flux_sync.this](https://registry.terraform.io/providers/fluxcd/flux/0.5.1/docs/data-sources/sync) | data source |
| [github_repository.cluster](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/data-sources/repository) | data source |
| [github_repository.extras](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/data-sources/repository) | data source |
| [kubectl_file_documents.install](https://registry.terraform.io/providers/gavinbunney/kubectl/1.13.0/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.sync](https://registry.terraform.io/providers/gavinbunney/kubectl/1.13.0/docs/data-sources/file_documents) | data source |

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
| <a name="input_istio_control_plane_yaml"></a> [istio\_control\_plane\_yaml](#input\_istio\_control\_plane\_yaml) | yaml content of istio control plane configuration | `string` | n/a | yes |
| <a name="input_istio_gateways_yaml"></a> [istio\_gateways\_yaml](#input\_istio\_gateways\_yaml) | yaml content of istio gateway configuration | `string` | n/a | yes |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | Version of Istio, this will read the apropriate operator config within this repo | `string` | n/a | yes |
| <a name="input_registry_flux"></a> [registry\_flux](#input\_registry\_flux) | Artifact registry to pull images from for flux | `string` | `"ghcr.io/fluxcd"` | no |
| <a name="input_registry_istio"></a> [registry\_istio](#input\_registry\_istio) | Artifact registry to pull images from for istio | `string` | `"gcr.io/istio-release"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->