# aws-eks

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.63.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.63.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ../aws-irsa | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ../aws-irsa | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 17.20.0 |
| <a name="module_external_dns"></a> [external\_dns](#module\_external\_dns) | ../aws-irsa | n/a |
| <a name="module_fluent_bit"></a> [fluent\_bit](#module\_fluent\_bit) | ../aws-irsa | n/a |
| <a name="module_loadbalancer"></a> [loadbalancer](#module\_loadbalancer) | ../aws-irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_identity_provider_config.keycloak](https://registry.terraform.io/providers/hashicorp/aws/3.63.0/docs/resources/eks_identity_provider_config) | resource |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/3.63.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/3.63.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.cert_manager](https://registry.terraform.io/providers/hashicorp/aws/3.63.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/3.63.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.external_dns](https://registry.terraform.io/providers/hashicorp/aws/3.63.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.fluent_bit](https://registry.terraform.io/providers/hashicorp/aws/3.63.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | Access rights, derived from roles | `list(string)` | `[]` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability Zones | `list(string)` | n/a | yes |
| <a name="input_cluster_identity_providers"></a> [cluster\_identity\_providers](#input\_cluster\_identity\_providers) | OIDC connection for external keycloak | `any` | n/a | yes |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | EKS k8s version | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Cluster identification string | `string` | n/a | yes |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | List of Node worker groups | `any` | n/a | yes |
| <a name="input_roles"></a> [roles](#input\_roles) | Access rights, derived from roles | <pre>list(object({<br>    groups   = list(string)<br>    rolearn  = string<br>    username = string<br>  }))</pre> | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | All subnets which nodes can be in | `list(string)` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | Access rights, derived from roles | <pre>list(object({<br>    groups   = list(string)<br>    userarn  = string<br>    username = string<br>  }))</pre> | `[]` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC which EKS cluster resides in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cert_manager_config"></a> [cert\_manager\_config](#output\_cert\_manager\_config) | Configuration for Cert Manager |
| <a name="output_cluster_autoscaler_config"></a> [cluster\_autoscaler\_config](#output\_cluster\_autoscaler\_config) | Configuration for Cluster Autoscaler |
| <a name="output_external_dns_config"></a> [external\_dns\_config](#output\_external\_dns\_config) | Configuration for External DNS |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Kube config for the created EKS cluster |
| <a name="output_loadbalancer_config"></a> [loadbalancer\_config](#output\_loadbalancer\_config) | Configuration for Loadbalancer |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | n/a |
<!-- END_TF_DOCS -->