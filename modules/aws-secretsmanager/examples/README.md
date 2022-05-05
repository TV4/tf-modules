# aws-secretsmanager - example usage

## Module
```terraform
module "secretsmanager" {
  for_each               = var.secrets
  source                 = "github.com/TV4/tf-modules//modules/aws-secretsmanager"
  kms_key                = each.key
  secretsmanager_entries = each.value.keys
  accounts               = each.value.accounts
  tags                   = local.default_tags
}
```

## TFvars
```terraform
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
## Structure
```console
/shared/service-1/api-key
/prod/cluster-1/component-1/private-key
```

secrets starting with `/shared/` will be available in both account-1 and account-2 while `/prod/` will only be available in account-2.
