# aws-secretsmanager

This SecretsManager skeleton module creates a structure of secrets **though not populating them**, which should be made available in different accounts.


<!-- BEGIN_TF_DOCS -->


## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Example

Read more about the example [here](./examples/README.md).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | List of AWS account ids which should get access to KMS key and associated secrets | `list(string)` | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | Key value for generating KMS key and prefix for secrets | `string` | n/a | yes |
| <a name="input_secretsmanager_entries"></a> [secretsmanager\_entries](#input\_secretsmanager\_entries) | List of secret entries | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags to add | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->