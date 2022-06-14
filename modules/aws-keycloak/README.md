# Keycloak on AWS

Terraform code is based on [https://github.com/aws-samples/keycloak-on-aws](https://github.com/aws-samples/keycloak-on-aws)

This is a solution for deploying [Keycloak](https://www.keycloak.org/) to AWS with high availability. Keycloak is a single sign-on (SSO) solution for web applications and RESTful web services. Keycloak's goal is to simplify security so that application developers can easily protect applications and services already deployed in their organizations. Out of the box, Keycloak provides security features that developers would normally have to write for themselves and can be easily customized for the individual needs of the organization. Keycloak provides a customizable user interface for login, registration, administration and account management. You can also use Keycloak as an integration platform to hook into existing LDAP and Active Directory servers. You can also delegate authentication to third-party identity providers, such as Facebook and Google+.

## Architecture diagram

![architecture](assets/01-keycloak-on-aws-architecture.svg)

1. NAT Gateway serves as the public access outlet for the private subnet.
2. Application Load Balancer distributes traffic to the AWS ECS Fargate application layer service. In addition, ALB also enables Sticky Sessions to implement distributed sessions. For more details, please refer to [Keycloak documentation](https://www.keycloak.org/docs/latest/server_installation/index.html#sticky-sessions).
3. You can choose Amazon Aurora Serverless to reduce costs or Amazon RDS MySQL for the database layer.
4. Both the database account password and the Keycloak administrator login account password are stored in AWS Secrets Manager
You will need to provide an AWS Certificate Manager certificate Arn to provide HTTPS access to the ALB


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
| <a name="java_opts"></a> [java\_opts](#input\_java\_opts) | JAVA_OPTS environment variable | `string` | `""` | no |
| <a name="database_instance_type"></a> [database\_instance\_type](#input\_database\_instance\_type) | Instance type to be used for the core instances | `string` | `"r5.large"` | no |
| <a name="database_instance_count"></a> [database\_instance\_count](#input\_database\_instance\_count) | Default database instances count | `number` | `2` | no |
| <a name="db_password_secret_arn"></a> [db\_password\_secret\_arn](#input\_db\_password\_secret\_arn) | ARN to the AWS Secrets Manager secret containing the database password | `string` | n/a | yes |
| <a name="keycloak_password_secret_arn"></a> [keycloak\_password\_secret\_arn](#input\_keycloak\_password\_secret\_arn) | ARN to the AWS Secrets Manager secret containing the Keycloak admin password | `string` | n/a | yes |
| <a name="keycloak_user"></a> [keycloak\_user](#input\_keycloak\_user) | Username for the Keycloak admin user | `string` | n/a | yes |
| <a name="tags"></a> [tags](#input\_tags) | Default tags to set on the created resources | `object({})` | n/a | yes |
| <a name="db_deletion_protection"></a> [db\_deletion\_protection](#input\\_db\_deletion\_protection) | Deletion protection for the database instances | `bool` | `true` | no |
| <a name="access_logs_s3_bucket_name"></a> [access\_logs\_s3\_bucket\_name](#input\_access\_logs\_s3\_bucket\_name) | Name of S3 bucket to store ALB access logs | `string` | n/a | yes |
| <a name="secrets_manager_kms_key_alias"></a> [secrets\_manager\_kms\_key\_alias](#input\_secrets\_manager\_kms\_key\_alias) | Alias for KMS key used to decrypt secrets | `string` | n/a | yes |
| <a name="vpc_id"></a> [vpc_id](#input\_vpc\_id) | Id of the VPC to create resources in | `string` | n/a | yes |
| <a name="private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet id's | `list(string)` | n/a | yes |
| <a name="public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnet id's | `list(string)` | n/a | yes |

## Outputs

| Name | Description | Type |
|------|-------------|------|
| <a name="aws_lb_dns_name"></a> [aws\_lb\_dns\_name](#input\_aws\_lb\_dns\_name) | The DNS name of the load balancer. | `string` |
| <a name="aws_lb_zone_id"></a> [aws\_lb\_zone\_id](#input\_aws\_lb\_zone\_id) | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). | `string` |

<!-- END_TF_DOCS -->