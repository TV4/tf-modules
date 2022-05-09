resource "aws_db_subnet_group" "KeyCloakDatabaseDBClusterSubnetsE36F1B1B" {
  name       = "keycloakdatabasedbclustersubnetse36f1b1b"
  subnet_ids = [aws_subnet.key_cloak_vpc_private_subnet_2.id, aws_subnet.key_cloak_vpc_private_subnet_2.id]
}

resource "aws_security_group" "KeyCloakDatabaseDBClusterSecurityGroup843B4392" {
  name        = "KeyCloakDatabaseDBClusterSecurityGroup843B4392"
  description = "KeyCloakDatabaseDBClusterSecurityGroup843B4392"
  vpc_id      = aws_vpc.key_cloak_vpc.id
}

resource "aws_security_group_rule" "KeyCloakDatabaseDBClusterSecurityGroup843B4392Ingress1" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.key_cloak_vpc.cidr_block]
  description       = "From ${aws_vpc.key_cloak_vpc.cidr_block}"
  security_group_id = aws_security_group.KeyCloakDatabaseDBClusterSecurityGroup843B4392.id
}

resource "aws_security_group_rule" "KeyCloakDatabaseDBClusterSecurityGroup843B4392Egress1" {
  type              = "egress"
  from_port         = 0
  to_port           = 65353
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow all outbound traffic by default"
  security_group_id = aws_security_group.KeyCloakDatabaseDBClusterSecurityGroup843B4392.id
}

resource "aws_security_group_rule" "KeyCloakDatabaseDBClusterSecurityGroup843B4392Ingress2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  cidr_blocks              = [aws_vpc.key_cloak_vpc.cidr_block]
  description              = "from keycloakfromnewvpcKeyCloakDatabaseDBClusterSecurityGroupB3AAFA04:3306"
  security_group_id        = aws_security_group.KeyCloakDatabaseDBClusterSecurityGroup843B4392.id
  source_security_group_id = aws_security_group.KeyCloakDatabaseDBClusterSecurityGroup843B4392.id
}

resource "aws_security_group_rule" "KeyCloakDatabaseDBClusterSecurityGroup843B4392Ingress3" {
  type                     = "ingress"
  from_port                = aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.port
  to_port                  = aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.port
  protocol                 = "tcp"
  description              = "from keycloakfromnewvpcKeyCloakDatabaseDBClusterSecurityGroupB3AAFA04:3306"
  security_group_id        = aws_security_group.KeyCloakDatabaseDBClusterSecurityGroup843B4392.id
  source_security_group_id = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
}

resource "aws_rds_cluster" "KeyCloakDatabaseDBCluster06E9C0E1" {
  cluster_identifier              = "keycloakdatabasedbcluster06e9c0e1"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.09.1"
  backup_retention_period         = 7
  db_cluster_parameter_group_name = "default.aurora-mysql5.7"
  db_subnet_group_name            = aws_db_subnet_group.KeyCloakDatabaseDBClusterSubnetsE36F1B1B.name
  master_username                 = "admin"
  master_password                 = "${var.db_password}"
  # master_password                 = "${SECRET.keycloakfromnewvpcKeyCloakDatabaseDBClusterSecretD9030AC53fdaad7efa858a3daf9490cf0a702aeb}:SecretString:password::"
  storage_encrypted               = true
  vpc_security_group_ids          = [aws_security_group.KeyCloakDatabaseDBClusterSecurityGroup843B4392.id]
}

resource "aws_rds_cluster_instance" "KeyCloakDatabaseDBClusterInstance12532FD3D" {
  cluster_identifier   = aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.id
  instance_class       = "db.${var.database_instance_type}"
  engine               = aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.engine
  engine_version       = aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.engine_version
  db_subnet_group_name = aws_db_subnet_group.KeyCloakDatabaseDBClusterSubnetsE36F1B1B.name
  depends_on = [
    aws_route.key_cloak_vpc_private_subnet_1_default_route,
    aws_route.key_cloak_vpc_private_subnet_2_default_route
  ]
}

resource "aws_rds_cluster_instance" "KeyCloakDatabaseDBClusterInstance2EE80EFE4" {
  cluster_identifier   = aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.id
  instance_class       = "db.${var.database_instance_type}"
  engine               = aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.engine
  engine_version       = aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.engine_version
  db_subnet_group_name = aws_db_subnet_group.KeyCloakDatabaseDBClusterSubnetsE36F1B1B.name
  depends_on = [
    aws_route.key_cloak_vpc_private_subnet_1_default_route,
    aws_route.key_cloak_vpc_private_subnet_2_default_route
  ]
}

#     "KeyCloakKCSecretF8498E5C": {
#       "Type": "AWS::SecretsManager::Secret",
#       "Properties": {
#         "GenerateSecretString": {
#           "ExcludePunctuation": true,
#           "GenerateStringKey": "password",
#           "PasswordLength": 12,
#           "SecretStringTemplate": "{\"username\":\"keycloak\"}"
#         }
#       },
#       "Metadata": {
#         "aws:cdk:path": "keycloak-from-new-vpc/KeyCloak/KCSecret/Resource"
#       }
#     },


#     "keycloakfromnewvpcKeyCloakDatabaseDBClusterSecretD9030AC53fdaad7efa858a3daf9490cf0a702aeb": {
#       "Type": "AWS::SecretsManager::Secret",
#       "Properties": {
#         "Description": {
#           "Fn::Join": [
#             "",
#             [
#               "Generated by the CDK for stack: ",
#               {
#                 "Ref": "AWS::StackName"
#               }
#             ]
#           ]
#         },
#         "GenerateSecretString": {
#           "ExcludeCharacters": " %+~`#$&*()|[]{}:;<>?!'/@\"\\",
#           "GenerateStringKey": "password",
#           "PasswordLength": 30,
#           "SecretStringTemplate": "{\"username\":\"admin\"}"
#         }
#       },
#       "Metadata": {
#         "aws:cdk:path": "keycloak-from-new-vpc/KeyCloak/Database/DBCluster/Secret/Resource"
#       }
#     },

#     "KeyCloakDatabaseDBClusterSecretAttachment50401C92": {
#       "Type": "AWS::SecretsManager::SecretTargetAttachment",
#       "Properties": {
#         "SecretId": {
#           "Ref": "keycloakfromnewvpcKeyCloakDatabaseDBClusterSecretD9030AC53fdaad7efa858a3daf9490cf0a702aeb"
#         },
#         "TargetId": {
#           "Ref": "KeyCloakDatabaseDBCluster06E9C0E1"
#         },
#         "TargetType": "AWS::RDS::DBCluster"
#       },
#       "Metadata": {
#         "aws:cdk:path": "keycloak-from-new-vpc/KeyCloak/Database/DBCluster/Secret/Attachment/Resource"
#       }
#     },
