# k8s-eks-lb-controller

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.2.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.4.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.aws_lb](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_service_account.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_images"></a> [container\_images](#input\_container\_images) | n/a | `map` | <pre>{<br>  "af-south-1": "877085696533.dkr.ecr.af-south-1.amazonaws.com",<br>  "ap-east-1": "800184023465.dkr.ecr.ap-east-1.amazonaws.com",<br>  "ap-northeast-1": "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com",<br>  "ap-northeast-2": "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com",<br>  "ap-northeast-3": "602401143452.dkr.ecr.ap-northeast-3.amazonaws.com",<br>  "ap-south-1": "602401143452.dkr.ecr.ap-south-1.amazonaws.com",<br>  "ap-southeast-1": "602401143452.dkr.ecr.ap-southeast-1.amazonaws.com",<br>  "ap-southeast-2": "602401143452.dkr.ecr.ap-southeast-2.amazonaws.com",<br>  "ca-central-1": "602401143452.dkr.ecr.ca-central-1.amazonaws.com",<br>  "cn-north-1": "918309763551.dkr.ecr.cn-north-1.amazonaws.com.cn",<br>  "cn-northwest-1": "961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn",<br>  "eu-central-1": "602401143452.dkr.ecr.eu-central-1.amazonaws.com",<br>  "eu-north-1": "602401143452.dkr.ecr.eu-north-1.amazonaws.com",<br>  "eu-south-1": "590381155156.dkr.ecr.eu-south-1.amazonaws.com",<br>  "eu-west-1": "602401143452.dkr.ecr.eu-west-1.amazonaws.com",<br>  "eu-west-2": "602401143452.dkr.ecr.eu-west-2.amazonaws.com",<br>  "eu-west-3": "602401143452.dkr.ecr.eu-west-3.amazonaws.com",<br>  "me-south-1": "558608220178.dkr.ecr.me-south-1.amazonaws.com",<br>  "sa-east-1": "602401143452.dkr.ecr.sa-east-1.amazonaws.com",<br>  "us-east-1": "602401143452.dkr.ecr.us-east-1.amazonaws.com",<br>  "us-east-2": "602401143452.dkr.ecr.us-east-2.amazonaws.com",<br>  "us-gov-east-1": "151742754352.dkr.ecr.us-gov-east-1.amazonaws.com",<br>  "us-gov-west-1": "013241004608.dkr.ecr.us-gov-west-1.amazonaws.com",<br>  "us-west-1": "602401143452.dkr.ecr.us-west-1.amazonaws.com",<br>  "us-west-2": "602401143452.dkr.ecr.us-west-2.amazonaws.com"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Cluster name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | Role ARN | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | AWS VPC | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->