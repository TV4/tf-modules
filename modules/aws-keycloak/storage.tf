resource "aws_db_subnet_group" "keycloak" {
  name       = "keycloak"
  subnet_ids = var.private_subnets
  tags       = local.default_tags
}

resource "aws_security_group" "db_cluster" {
  name   = "Keycloak DB Cluster"
  vpc_id = var.vpc_id
  tags   = local.default_tags
}

resource "aws_security_group_rule" "db_ingress_3306_tcp" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  description       = "From ${data.aws_vpc.vpc.cidr_block}"
  security_group_id = aws_security_group.db_cluster.id
}

resource "aws_security_group_rule" "db_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65353
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow all outbound traffic by default"
  security_group_id = aws_security_group.db_cluster.id
}

resource "aws_security_group_rule" "db_ingress_3306_tcp_internal" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_cluster.id
  source_security_group_id = aws_security_group.db_cluster.id
}

resource "aws_security_group_rule" "db_ingress_app_connections" {
  type                     = "ingress"
  from_port                = aws_rds_cluster.db_cluster.port
  to_port                  = aws_rds_cluster.db_cluster.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_cluster.id
  source_security_group_id = aws_security_group.keycloak_container_service.id
}

data "aws_secretsmanager_secret" "rds_master_password" {
  arn = var.db_password_secret_arn
}

data "aws_secretsmanager_secret_version" "rds_master_password" {
  secret_id = data.aws_secretsmanager_secret.rds_master_password.id
}

resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier_prefix       = "keycloak-db-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.09.1"
  backup_retention_period         = 7
  db_cluster_parameter_group_name = "default.aurora-mysql5.7"
  db_subnet_group_name            = aws_db_subnet_group.keycloak.name
  master_username                 = "admin"
  master_password                 = data.aws_secretsmanager_secret_version.rds_master_password.secret_string
  storage_encrypted               = true
  vpc_security_group_ids          = [aws_security_group.db_cluster.id]
  final_snapshot_identifier       = "keycloak-db-cluster"
  copy_tags_to_snapshot           = true
  deletion_protection             = var.db_deletion_protection
  tags                            = local.default_tags
}

resource "aws_rds_cluster_instance" "keycloak_db_instance" {
  count                = var.database_instance_count
  identifier           = "${aws_rds_cluster.db_cluster.cluster_identifier}-${count.index}"
  cluster_identifier   = aws_rds_cluster.db_cluster.id
  instance_class       = "db.${var.database_instance_type}"
  engine               = aws_rds_cluster.db_cluster.engine
  engine_version       = aws_rds_cluster.db_cluster.engine_version
  db_subnet_group_name = aws_db_subnet_group.keycloak.name
  tags                 = local.default_tags
}