# Keycloak Realm
Creates users, groups and identity providers within a Keycloak realm.

## Terraform Stack

This Keycloak setup is split into three parts/modules, each with its own scope.

1. Spinning up a Keycloak server with an admin user [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak)
2. Creating realms, terraform-cli clients as management users with limited permissions within the realm. [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-realm](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-realm)
3. Creating users, groups, identity providers etc within the realm, authenticating as a user with permissions in this realm only [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-configuration](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-configuration)

## Dependencies

* A running Keycloak instance. A realm with a terraform-cli OpenID client for communication with the Keycloak API

## Example

```

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
  url           = sso.tvm.telia.com
  alias         = "admin"
  initial_login = false
  base_path     = ""
}

provider "keycloak" {
  client_id     = "xxxxx"
  client_secret = "yyyy"
  realm         = module.keycloak_realm["tvm"].client_credentials.realm_id
  url           = sso.tvm.telia.com
  alias         = "tvm"
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

module "keycloak_tvm" {
  providers = {
    keycloak = keycloak.tvm
  }
  source                    = "github.com/TV4/tf-modules//modules/aws-keycloak-configuration/"
  realm_id                  = module.keycloak_realm.client_credentials.realm_id
  groups                    = ["Cats", "Dogs"]
  users                     = {
                              "oew493" = {
                                  "github_username" = "twiden",
                                  "github_user_id"  = "7657952",
                                  "email"           = "tobias.widen@tv4.se",
                                  "first_name"      = "Tobias",
                                  "last_name"       = "Widén",
                                  "groups"          = ["Dogs"]
                                }
                          }
  github_oidc_client_id     = "xxx"
  github_oidc_client_secret = "yyy"
  k8s_clusters              = ["kubernetes-emerald", "kubernetes-ruby"]
  depends_on                = [module.keycloak_realm]
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
| <a name="realm\_id"></a> [realm_id](#input\_realm\_id) | ID of the realm to create resources in | `string` | n/a |
| <a name="groups"></a> [groups](#input\_groups) | List of group names | `list(string)` | n/a |
| <a name="github\_oidc\_client\_id"></a> [github\_oidc\_client_id](#input\_github\_oidc\_client\_id) | GitHub OIDC client id (For Idp) | `string` | n/a |
| <a name="github\_oidc\_client\_secret"></a> [github\_oidc\_client\_secret](#input\_github\_oidc\_client\_secret) | GitHub OIDC client secret (For Idp) | `string` | n/a |
| <a name="k8s\_clusters"></a> [k8s\_clusters](#input\_k8s\_clusters) | List of kubernetes cluster names | `list(string)` | n/a |
| <a name="users"></a> [users](#input\_users) | Users and attributes | `object` | n/a |

## Outputs

| Name | Description | Type |
|------|-------------|------|

<!-- END_TF_DOCS -->