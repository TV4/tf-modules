# SecretsManager skeleton module

This module create a structure of secrets **though not populating them**, which should be made available in different accounts.

## Example usage
#### Module
```
module "secretsmanager" {
  for_each               = var.secrets
  source                 = "github.com/TV4/tf-modules//aws/secretsmanager"
  kms_key                = each.key
  secretsmanager_entries = each.value.keys
  accounts               = each.value.accounts
  tags                   = local.default_tags
}
```

#### TFvars
```
secrets = {
  shared = {
    accounts = [
      "accountid-1", # Test
      "accountid-2", # Prod
    ]
    keys = [
      "service-1/api-key",
    ]
  }
  prod = {
    accounts = [
      "accountid-2" # Prod
    ]
    keys = [
      "cluster-1/component-1/private-key"
    ]
  }
}
```
#### Structure
```
/shared/service-1/api-key
/prod/cluster-1/component-1/private-key
```

secrets starting with `/shared/` will be available in both account-1 and account-2 while `/prod/` will only be available in account-2.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

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