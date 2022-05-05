# k8s-flux-extras

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | 0.5.1 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 4.13.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.4.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 4.13.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.4.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_repository_deploy_key.extras](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/resources/repository_deploy_key) | resource |
| [kubernetes_secret.extras](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [tls_private_key.extras](https://registry.terraform.io/providers/hashicorp/tls/3.1.0/docs/resources/private_key) | resource |
| [github_repository.extras](https://registry.terraform.io/providers/integrations/github/4.13.0/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_branch"></a> [branch](#input\_branch) | Git branch which to use for flux repo | `string` | `"master"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Name of cluster in the flux repo | `string` | n/a | yes |
| <a name="input_cluster_repo"></a> [cluster\_repo](#input\_cluster\_repo) | Name of flux repo | `string` | n/a | yes |
| <a name="input_cluster_resource"></a> [cluster\_resource](#input\_cluster\_resource) | Optional cluster resource to depend on | <pre>object({<br>    name = string<br>    arn  = string<br>  })</pre> | <pre>{<br>  "arn": "",<br>  "name": ""<br>}</pre> | no |
| <a name="input_extra_repos"></a> [extra\_repos](#input\_extra\_repos) | List of private github repos which should add the same deploy key. | `list(string)` | `[]` | no |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | Owner of flux repo, used in coalition with cluster\_repo to figure out github path | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->