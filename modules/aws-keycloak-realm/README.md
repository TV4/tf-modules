# Keycloak Realm
Creates a new Realm within Keycloak [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak) and a terraform-cli OpenID client for future communication and configuration of this realm. 

## Terraform Stack

This Keycloak setup is split into three parts/modules, each with its own scope.

1. Spinning up a Keycloak server with an admin user [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak)
2. Creating realms, terraform-cli clients as management users with limited permissions within the realm. [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-realm](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-realm)
3. Creating users, groups, identity providers etc within the realm, authenticating as a user with permissions in this realm only [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-configuration](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-configuration)

## Dependencies

* A running Keycloak instance with master user.
* Master users password for communication with the Keycloak API.

## Example

```terraform
module "keycloak" {
  source                              = "github.com/TV4/tf-modules//modules/aws-keycloak"
  tags                                = {"Terraform" = true}
  certificate_arn                     = "arn:aws:acm:eu-west-1:xxxxxxxxxxxx:certificate/4f2f1aa4-5082-45fd-b984-bf2d0bb54d6a"
  min_containers                      = 2
  max_containers                      = 10
  auto_scaling_target_cpu_utilization = 75
  database_instance_type              = "r5.large"
  db_password_secret_arn              = "arn:aws:secretsmanager:eu-west-1:xxxxxxxxxxxx:secret:/kc-db-pwd-pVJtCP"
  keycloak_password_secret_arn        = "arn:aws:secretsmanager:eu-west-1:xxxxxxxxxxxx:secret:/kc-master-pwd-pVJtCP"
  keycloak_user                       = "admin"
  keycloak_url                        = "sso.tvm.telia.com"
  keycloak_verbose_logging            = true
  db_deletion_protection              = true
  secrets_manager_kms_key_alias       = "secretsmanager-eks-prod"
  vpc_id                              = module.keycloak_vpc.vpc_id
  private_subnets                     = module.keycloak_vpc.private_subnets
  public_subnets                      = module.keycloak_vpc.public_subnets
  depends_on                          = [module.keycloak_vpc]
}

provider "keycloak" {
  client_id     = "admin-cli"
  username      = "admin"
  password      = "passw0rd"
  url           = "sso.tvm.telia.com"
  alias         = "admin"
  initial_login = false
  base_path     = ""
}

module "keycloak_realm" {
  providers = {
    keycloak = keycloak.admin
  }
  source     = "github.com/TV4/tf-modules//modules/aws-keycloak-realm/"
  realm_name = "tvm"
  depends_on = [module.keycloak]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.17.1, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.17.1, < 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="realm_name"></a> [realm\_name](#input\_realm\_name) | Name of the realm to create | `string` | n/a | yes |

## Outputs

| Name | Description | Type |
|------|-------------|------|
| <a name="client\_credentials"></a> [client\_credentials](#output\_client\_credentials) | OpenID Authentication information for the created realm | `string` |

<!-- END_TF_DOCS -->