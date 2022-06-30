# Keycloak on AWS

This is a solution for deploying [Keycloak](https://www.keycloak.org/) to AWS with high availability. It leverages ECS as an orchestration platform, EFS for cross container file sharing and RDS for the application shared state. 

Keycloak is a single sign-on (SSO) solution for web applications and RESTful web services. Keycloak's goal is to simplify security so that application developers can easily protect applications and services already deployed in their organizations. Out of the box, Keycloak provides security features that developers would normally have to write for themselves and can be easily customized for the individual needs of the organization. Keycloak provides a customizable user interface for login, registration, administration and account management. You can also use Keycloak as an integration platform to hook into existing LDAP and Active Directory servers. You can also delegate authentication to third-party identity providers, such as Facebook and Google+.

Terraform code is based on [https://github.com/aws-samples/keycloak-on-aws](https://github.com/aws-samples/keycloak-on-aws) but modified in several ways (Including upgrading the Keycloak version from 12 to 18)

## Terraform Stack

This Keycloak setup is split into three parts/modules, each with its own scope.

1. Spinning up a Keycloak server with an admin user [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak)
2. Creating realms, terraform-cli clients as management users with limited permissions within the realm. [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-realm](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-realm)
3. Creating users, groups, identity providers etc within the realm, authenticating as a user with permissions in this realm only [https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-configuration](https://github.com/TV4/tf-modules/tree/main/modules/aws-keycloak-configuration)

## Architecture diagram

![architecture](assets/01-keycloak-on-aws-architecture.svg)

1. NAT Gateway serves as the public access outlet for the private subnet.
2. Application Load Balancer distributes traffic to the AWS ECS Fargate application layer service. In addition, ALB also enables Sticky Sessions to implement distributed sessions. For more details, please refer to [Keycloak documentation](https://www.keycloak.org/docs/latest/server_installation/index.html#sticky-sessions).
3. You can choose Amazon Aurora Serverless to reduce costs or Amazon RDS MySQL for the database layer.
4. Both the database account password and the Keycloak administrator login account password are stored in AWS Secrets Manager
You will need to provide an AWS Certificate Manager certificate Arn to provide HTTPS access to the ALB
5. The Keycloak ECS Service has two bootstrap containers that run and terminate before the actual Keycloak instances. Bootstrapping of database schema and self signed certificates (stored and shared between containers through EFS) for traffic between load balancer and containers.

## Dependencies

* An existing VPC with public and private subnets and internet access from the subnets. DNS hostnames must be enabled within the VPC for container-EFS connectivity.
* An existing ACM certificate as input.
* Pregenerated passwords for Keycloak master user and database access stored in AWS Secrets Manager.

## Example

```
module "keycloak_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "keycloak-vpc"
  cidr   = "10.0.0.0/16"
  azs    = data.aws_availability_zones.available.names

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true
  enable_dns_support     = true

  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_suffix = "public"
  public_subnet_tags   = { "Tier" = "Public" }

  private_subnets       = ["10.0.64.0/18", "10.0.128.0/18", "10.0.192.0/18"]
  private_subnet_suffix = "private"
  private_subnet_tags   = { "Tier" = "Private" }

  tags = merge(local.default_tags, { "Application" : "Keycloak" })
}

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

data "aws_availability_zones" "available" {
  state = "available"
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
| <a name="certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | AWS Certificate Manager certificate Arn to provide HTTPS access to the ALB | `string` | n/a | yes |
| <a name="min_containers"></a> [min\_containers](#input\_min\_containers) | Minimum containers count | `number` | `2` | no |
| <a name="max_containers"></a> [max\_containers](#input\_max\_containers) | Maximum containers count | `number` | `10` | no |
| <a name="auto_scaling_target_cpu_utilization"></a> [auto\_scaling\_target\_cpu\_utilization](#input\_auto\_scaling\_target\_cpu\_utilization) | Auto scaling target cpu utilization | `number` | `75` | no |
| <a name="database_instance_type"></a> [database\_instance\_type](#input\_database\_instance\_type) | Instance type to be used for the core instances | `string` | `"r5.large"` | no |
| <a name="database_instance_count"></a> [database\_instance\_count](#input\_database\_instance\_count) | Default database instances count | `number` | `2` | no |
| <a name="db_password_secret_arn"></a> [db\_password\_secret\_arn](#input\_db\_password\_secret\_arn) | ARN to the AWS Secrets Manager secret containing the database password | `string` | n/a | yes |
| <a name="keycloak_password_secret_arn"></a> [keycloak\_password\_secret\_arn](#input\_keycloak\_password\_secret\_arn) | ARN to the AWS Secrets Manager secret containing the Keycloak admin password | `string` | n/a | yes |
| <a name="keycloak_user"></a> [keycloak\_user](#input\_keycloak\_user) | Username for the Keycloak admin user | `string` | n/a | yes |
| <a name="tags"></a> [tags](#input\_tags) | Default tags to set on the created resources | `object({})` | n/a | yes |
| <a name="db_deletion_protection"></a> [db\_deletion\_protection](#input\\_db\_deletion\_protection) | Deletion protection for the database instances | `bool` | `true` | no |
| <a name="secrets_manager_kms_key_alias"></a> [secrets\_manager\_kms\_key\_alias](#input\_secrets\_manager\_kms\_key\_alias) | Alias for KMS key used to decrypt secrets | `string` | n/a | yes |
| <a name="vpc_id"></a> [vpc_id](#input\_vpc\_id) | Id of the VPC to create resources in | `string` | n/a | yes |
| <a name="private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet id's | `list(string)` | n/a | yes |
| <a name="public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnet id's | `list(string)` | n/a | yes |
| <a name="keycloak_url"></a> [keycloak\_url](#input\_keycloak\_url) | FQDN for this keycloak instance. Used for creating internal certificates | `string` | n/a | yes |
| <a name="keycloak_verbose_logging"></a> [keycloak\_verbose\_logging](#input\_keycloak\_verbose\_logging) | Enables verbose logging for the keycloak instances | `bool` | `false` | no |

## Outputs

| Name | Description | Type |
|------|-------------|------|
| <a name="aws_lb_dns_name"></a> [aws\_lb\_dns\_name](#output\_aws\_lb\_dns\_name) | The DNS name of the load balancer. | `string` |
| <a name="aws_lb_zone_id"></a> [aws\_lb\_zone\_id](#output\_aws\_lb\_zone\_id) | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). | `string` |

<!-- END_TF_DOCS -->