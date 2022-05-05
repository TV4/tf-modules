module "secretsmanager" {
  for_each               = var.secrets
  source                 = "github.com/TV4/tf-modules//modules/aws-secretsmanager"
  kms_key                = each.key
  secretsmanager_entries = each.value.keys
  accounts               = each.value.accounts
  tags                   = local.default_tags
}