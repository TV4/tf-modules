# k8s-eks-external-dns

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_oidc"></a> [oidc](#module\_oidc) | ../k8s-eks-oidc-service-account | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Cluster name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | Role ARN | `string` | n/a | yes |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | route53 zone name | `string` | n/a | yes |
| <a name="input_zone_type"></a> [zone\_type](#input\_zone\_type) | route53 zone type private/public | `string` | `"public"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->