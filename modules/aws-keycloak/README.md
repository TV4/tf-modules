# Keycloak on AWS

Terraform code is based on [https://github.com/aws-samples/keycloak-on-aws](https://github.com/aws-samples/keycloak-on-aws)

This is a solution for deploying [Keycloak](https://www.keycloak.org/) to AWS with high availability. Keycloak is a single sign-on (SSO) solution for web applications and RESTful web services. Keycloak's goal is to simplify security so that application developers can easily protect applications and services already deployed in their organizations. Out of the box, Keycloak provides security features that developers would normally have to write for themselves and can be easily customized for the individual needs of the organization. Keycloak provides a customizable user interface for login, registration, administration and account management. You can also use Keycloak as an integration platform to hook into existing LDAP and Active Directory servers. You can also delegate authentication to third-party identity providers, such as Facebook and Google+.

## Architecture diagram

![architecture](assets/01-keycloak-on-aws-architecture.svg)

1. NAT Gateway serves as the public access outlet for the private subnet.
2. Application Load Balancer distributes traffic to the AWS ECS Fargate application layer service. In addition, ALB also enables Sticky Sessions to implement distributed sessions. For more details, please refer to [Keycloak documentation](https://www.keycloak.org/docs/latest/server_installation/index.html#sticky-sessions).
3. You can choose Amazon Aurora Serverless to reduce costs or Amazon RDS MySQL for the database layer.
4. Both the database account password and the Keycloak administrator login account password are automatically generated using AWS Secrets Management to ensure security.
You will need to provide an AWS Certificate Manager certificate for Arn to provide HTTPS access to the ALB


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.74.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.74.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.KeyCloakKeyCloakContainerSerivceServiceTaskCountTargetCpuScaling1480DC0B](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.KeyCloakKeyCloakContainerSerivceServiceTaskCountTarget0EDF86B3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.KeyCloakKeyCloakContainerSerivceLogGroup010F2AAE](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_subnet_group.KeyCloakDatabaseDBClusterSubnetsE36F1B1B](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ecs_cluster.KeyCloakKeyCloakContainerSerivceClusterA18E44FF](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.KeyCloakKeyCloakContainerSerivceService79D3F427](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.KeyCloakKeyCloakContainerSerivceTaskDef30C9533A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_eip.key_cloak_vpc_public_subnet_1_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_role.KeyCloakKeyCloakContainerSerivceTaskDefTaskRole0DC4D418](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.KeyCloakKeyCloakContainerSerivceTaskRole0658CED2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.KeyCloakKeyCloakContainerSerivceTaskRoleDefaultPolicyA2321E87](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-role-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.key_cloak_vpc_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_internet_gateway_attachment.key_cloak_vpc_igw_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway_attachment) | resource |
| [aws_lb.ContainerSerivceALBE100B67D](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.KeyCloakKeyCloakContainerSerivceALBHttpsListener140F85B9](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.ECSTargetGroupCE3EF52C](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_nat_gateway.key_cloak_vpc_public_subnet_1_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.KeyCloakDatabaseDBClusterInstance12532FD3D](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_instance.KeyCloakDatabaseDBClusterInstance2EE80EFE4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_route.key_cloak_vpc_private_subnet_1_default_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.key_cloak_vpc_private_subnet_2_default_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.key_cloak_vpc_public_subnet_1_default_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.key_cloak_vpc_public_subnet_2_default_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.key_cloak_vpc_private_subnet_1_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.key_cloak_vpc_private_subnet_2_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.key_cloak_vpc_public_subnet_1_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.key_cloak_vpc_public_subnet_2_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.key_cloak_vpc_private_subnet_1_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.key_cloak_vpc_private_subnet_2_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.key_cloak_vpc_public_subnet_1_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.key_cloak_vpc_public_subnet_2_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.KeyCloakDatabaseDBClusterSecurityGroup843B4392](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.KeyCloakKeyCloakContainerSerivceALBSecurityGroup8F5103C6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.KeyCloakDatabaseDBClusterSecurityGroup843B4392Egress1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.KeyCloakDatabaseDBClusterSecurityGroup843B4392Ingress1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.KeyCloakDatabaseDBClusterSecurityGroup843B4392Ingress2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.KeyCloakDatabaseDBClusterSecurityGroup843B4392Ingress3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.KeyCloakKeyCloakContainerSerivceServiceSecurityGroupfromkeycloakfromnewvpcKeyCloakKeyCloakContainerSerivceALBSecurityGroupFD2CC2BD8443F1CBDED3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress54200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress55200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress57600](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress7600](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress8443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.key_cloak_vpc_private_subnet_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.key_cloak_vpc_private_subnet_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.key_cloak_vpc_public_subnet_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.key_cloak_vpc_public_subnet_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.key_cloak_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_scaling_target_cpu_utilization"></a> [auto\_scaling\_target\_cpu\_utilization](#input\_auto\_scaling\_target\_cpu\_utilization) | n/a | `number` | `75` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_database_instance_type"></a> [database\_instance\_type](#input\_database\_instance\_type) | Instance type to be used for the core instances | `string` | `"r5.large"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | n/a | `string` | n/a | yes |
| <a name="input_java_opts"></a> [java\_opts](#input\_java\_opts) | JAVA\_OPTS environment variable | `string` | n/a | yes |
| <a name="input_keycloak_password"></a> [keycloak\_password](#input\_keycloak\_password) | n/a | `string` | n/a | yes |
| <a name="input_keycloak_user"></a> [keycloak\_user](#input\_keycloak\_user) | n/a | `string` | n/a | yes |
| <a name="input_max_containers"></a> [max\_containers](#input\_max\_containers) | maximum containers count | `number` | `10` | no |
| <a name="input_min_containers"></a> [min\_containers](#input\_min\_containers) | minimum containers count | `number` | `2` | no |
| <a name="input_private_subnet_1_cidr_block"></a> [private\_subnet\_1\_cidr\_block](#input\_private\_subnet\_1\_cidr\_block) | n/a | `string` | `"10.0.128.0/18"` | no |
| <a name="input_private_subnet_2_cidr_block"></a> [private\_subnet\_2\_cidr\_block](#input\_private\_subnet\_2\_cidr\_block) | n/a | `string` | `"10.0.192.0/18"` | no |
| <a name="input_public_subnet_1_cidr_block"></a> [public\_subnet\_1\_cidr\_block](#input\_public\_subnet\_1\_cidr\_block) | n/a | `string` | `"10.0.0.0/18"` | no |
| <a name="input_public_subnet_2_cidr_block"></a> [public\_subnet\_2\_cidr\_block](#input\_public\_subnet\_2\_cidr\_block) | n/a | `string` | `"10.0.64.0/18"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `object({})` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | n/a | `string` | `"10.0.0.0/16"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->