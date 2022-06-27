resource "aws_ecs_cluster" "keycloak_ecs_cluster" {
  name = "keycloak-${local.kc_id}"
  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  role       = aws_iam_role.keycloak_container_service_task_execution_role.name
  policy_arn = data.aws_iam_policy.amazon_ec2_container_registry_read_only.arn
}

resource "aws_iam_role" "keycloak_container_service_task_execution_role" {
  name                = "keycloak_container_service_task_execution_role"
  managed_policy_arns = [data.aws_iam_policy.amazon_ec2_container_registry_read_only.arn]
  tags                = local.default_tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "keycloak_container_service_task_execution_role" {
  name = "keycloak_container_service_task_execution_role"
  role = aws_iam_role.keycloak_container_service_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.keycloak_ecs_service.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = [
          var.db_password_secret_arn,
          var.keycloak_password_secret_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [data.aws_kms_key.secretsmanager.arn]
      },
    ]
  })
}
resource "aws_iam_policy" "keycloak_container_service_task_role_efs" {
  name   = "keycloak_container_service_task_role_efs"
  path   = "/"
  policy = data.aws_iam_policy_document.keycloak_container_service_task_role_efs.json
}

resource "aws_iam_policy_attachment" "attach" {
  name       = "keycloak_container_service_task_role_efs-attachment"
  roles      = [aws_iam_role.keycloak_container_service_task_role.name]
  policy_arn = aws_iam_policy.keycloak_container_service_task_role_efs.arn
}

resource "aws_efs_mount_target" "efs-mt" {
  count           = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.container_certs.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

data "aws_iam_policy_document" "keycloak_container_service_task_role_efs" {
  statement {
    actions = [
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount"
    ]
    resources = [aws_efs_file_system.container_certs.arn]
    condition {
      test     = "StringEquals"
      values   = ["elasticfilesystem:AccessPointArn"]
      variable = "elasticfilesystem:AccessPointArn"
    }
  }
}

resource "aws_iam_role" "keycloak_container_service_task_role" {
  tags = local.default_tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_efs_file_system" "container_certs" {
  creation_token = "keycloak_container_certs"
  encrypted      = true
  tags           = merge(local.default_tags, { "Name" = "Keycloak container certs" })
}

resource "aws_efs_access_point" "container_certs" {
  file_system_id = aws_efs_file_system.container_certs.id
  root_directory { path = "/" }
  tags = merge(local.default_tags, { "Name" = "Keycloak container certs" })
}

data "aws_iam_policy_document" "enforce_access_through_efs_access_point" {
  statement {
    sid    = "efs-enforce-access-through-efs-access-point"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["elasticfilesystem:Client*"]
    resources = [aws_efs_file_system.container_certs.arn]
    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values   = [aws_efs_access_point.container_certs.arn]
    }
  }
}

resource "aws_efs_file_system_policy" "container_certs" {
  file_system_id = aws_efs_file_system.container_certs.id
  policy         = data.aws_iam_policy_document.enforce_access_through_efs_access_point.json
}

resource "aws_ecs_task_definition" "keycloak_task_definition" {
  tags                     = local.default_tags
  family                   = "keycloak-${local.kc_id}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.keycloak_container_service_task_role.arn
  execution_role_arn       = aws_iam_role.keycloak_container_service_task_execution_role.arn
  cpu                      = 4096
  memory                   = 30720

  volume {
    name = "container_certs"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.container_certs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.container_certs.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = <<DEFINITION
  [{
		"name": "keycloak-cert",
		"image": "mirror.gcr.io/library/alpine:3.16.0",
		"essential": false,
    "cpu": 68,
    "memory": 96,
    "entryPoint": ["sh", "-c"],
		"command": [
      "apk update && apk add --no-cache openssl && openssl req -x509 -nodes -days 3650 -subj \"/C=CA/ST=QC/O=Company Inc/CN=${var.keycloak_url}\" -newkey rsa:2048 -keyout /opt/container_certs/selfsigned.key -out /opt/container_certs/selfsigned.crt && chown 1000:0 /opt/container_certs/*"
    ],
		"logConfiguration": {
			"logDriver": "awslogs",
			"options": {
				"awslogs-group": "${aws_cloudwatch_log_group.keycloak_ecs_service.name}",
				"awslogs-region": "${data.aws_region.current.name}",
				"awslogs-stream-prefix": "keycloak-cert"
			}
		},
    "mountPoints": [
      {
        "sourceVolume": "container_certs",
        "containerPath": "/opt/container_certs"
      }
    ]
	},
  {
		"name": "bootstrap",
		"image": "${local.mysql_bootstrap_image}",
		"essential": false,
    "cpu": 1024,
    "memory": 1024,
		"command": ["sh", "-c", "mysql -u$DB_USER -p$DB_PASSWORD -h$DB_ADDR -e \"CREATE DATABASE IF NOT EXISTS $DB_NAME\""],
    "secrets": [
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${var.db_password_secret_arn}"
      }
    ],
		"environment": [{
				"name": "DB_NAME",
				"value": "${local.rds_database_name}"
			},
			{
				"name": "DB_USER",
				"value": "${local.rds_master_username}"
			},
			{
				"name": "DB_ADDR",
				"value": "${aws_rds_cluster.db_cluster.endpoint}"
		  }
		],
		"logConfiguration": {
			"logDriver": "awslogs",
			"options": {
				"awslogs-group": "${aws_cloudwatch_log_group.keycloak_ecs_service.name}",
				"awslogs-region": "${data.aws_region.current.name}",
				"awslogs-stream-prefix": "bootstrap"
			}
		}
	},
	{
		"name": "keycloak",
		"cpu": 3000,
		"memory": 29600,
		"networkMode": "awsvpc",
		"requiredCapabilities": "FARGATE",
    "entrypoint":  ["/opt/keycloak/bin/kc.sh"],
    "command": ${local.keycloak_command},
		"image": "${local.keycloak_image}",
		"essential": true,
		"dependsOn": [{
			"condition": "SUCCESS",
			"containerName": "bootstrap"
		},
    {
			"condition": "SUCCESS",
			"containerName": "keycloak-cert"
		}],
    "secrets": [
      {
        "name": "KEYCLOAK_ADMIN_PASSWORD",
        "valueFrom": "${var.keycloak_password_secret_arn}"
      },
      {
        "name": "KC_DB_PASSWORD",
        "valueFrom": "${var.db_password_secret_arn}"
      }
    ],
		"environment": [{
				"name": "KC_HTTPS_CERTIFICATE_FILE",
				"value": "/opt/container_certs/selfsigned.crt"
			},
      {
				"name": "KC_HTTPS_CERTIFICATE_KEY_FILE",
				"value": "/opt/container_certs/selfsigned.key"
			},
      {
				"name": "KC_DB_URL_HOST",
				"value": "${aws_rds_cluster.db_cluster.endpoint}"
			},
			{
				"name": "KC_DB_SCHEMA", 
				"value": "${local.rds_database_name}"
			},
			{
				"name": "KC_DB_URL_DATABASE", 
				"value": "${local.rds_database_name}"
			},
			{
				"name": "KC_DB_URL_PORT",
				"value": "3306"
			},
			{
				"name": "KC_HTTPS_PORT",
				"value": "8443"
			}, 
			{
				"name": "KC_DB_USERNAME",
				"value": "${local.rds_master_username}"
			},  
			{
				"name": "KC_DB",
				"value": "mysql"
			},
      {
				"name": "KC_PROXY",
				"value": "edge"
			},
			{
				"name": "KEYCLOAK_ADMIN",
				"value": "${var.keycloak_user}"
			}
		],
		"logConfiguration": {
			"logDriver": "awslogs",
			"options": {
				"awslogs-group": "${aws_cloudwatch_log_group.keycloak_ecs_service.name}",
				"awslogs-region": "${data.aws_region.current.name}",
				"awslogs-stream-prefix": "keycloak"
			}
		},
		"portMappings": [{
				"containerPort": 8443,
				"protocol": "tcp"
			},
			{
				"containerPort": 7600,
				"protocol": "tcp"
			},
			{
				"containerPort": 57600,
				"protocol": "tcp"
			},
			{
				"containerPort": 55200,
				"protocol": "udp"
			},
			{
				"containerPort": 54200,
				"protocol": "udp"
			}
		],
    "mountPoints": [
      {
        "sourceVolume": "container_certs",
        "containerPath": "/opt/container_certs"
      }
    ]
	}
]
  DEFINITION
}

resource "aws_cloudwatch_log_group" "keycloak_ecs_service" {
  name              = "keycloak-${local.kc_id}"
  retention_in_days = 30
  tags              = local.default_tags
}


resource "aws_ecs_service" "keycloak_ecs_service" {
  name                               = "keycloak-${local.kc_id}"
  cluster                            = aws_ecs_cluster.keycloak_ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.keycloak_task_definition.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  desired_count                      = var.min_containers
  enable_ecs_managed_tags            = false
  health_check_grace_period_seconds  = 120
  launch_type                        = "FARGATE"
  tags                               = local.default_tags

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = "keycloak"
    container_port   = 8443
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.keycloak_container_service.id]
    subnets          = var.private_subnets
  }

  depends_on = [
    aws_lb_target_group.ecs,
    aws_lb_listener.keycloak_https,

  ]
}

resource "aws_security_group" "efs" {
  description = "EFS"
  vpc_id      = var.vpc_id
  tags        = local.default_tags
}

resource "aws_security_group_rule" "ingress_nfs" {
  description              = "NFS/EFS"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.keycloak_container_service.id
}

resource "aws_security_group_rule" "ingress_nfs_transit_encryption" {
  description              = "NFS/EFS"
  from_port                = 2999
  to_port                  = 2999
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.keycloak_container_service.id
}

resource "aws_security_group" "keycloak_container_service" {
  description = "Keycloak ECS Service"
  vpc_id      = var.vpc_id
  tags        = local.default_tags
}

resource "aws_security_group_rule" "egress_nfs" {
  description              = "NFS/EFS"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "egress"
  security_group_id        = aws_security_group.keycloak_container_service.id
  source_security_group_id = aws_security_group.efs.id
}

resource "aws_security_group_rule" "egress_nfs_transit_encryption" {
  description              = "NFS/EFS"
  from_port                = 2999
  to_port                  = 2999
  protocol                 = "tcp"
  type                     = "egress"
  security_group_id        = aws_security_group.keycloak_container_service.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ingress7600" {
  description              = "kc jgroups-tcp"
  from_port                = 7600
  to_port                  = 7600
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = aws_security_group.keycloak_container_service.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ing_jgroups_tcp_fd" {
  description              = "kc jgroups-tcp-fd"
  from_port                = 57600
  to_port                  = 57600
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = aws_security_group.keycloak_container_service.id
  source_security_group_id = aws_security_group.keycloak_container_service.id
}

resource "aws_security_group_rule" "ing_jgroups_udp" {
  description              = "kc jgroups-udp"
  from_port                = 55200
  to_port                  = 55200
  protocol                 = "udp"
  type                     = "ingress"
  security_group_id        = aws_security_group.keycloak_container_service.id
  source_security_group_id = aws_security_group.keycloak_container_service.id
}

resource "aws_security_group_rule" "ing_jgroups_udp_fd" {
  description              = "kc jgroups-udp-fd"
  from_port                = 54200
  to_port                  = 54200
  protocol                 = "udp"
  type                     = "ingress"
  security_group_id        = aws_security_group.keycloak_container_service.id
  source_security_group_id = aws_security_group.keycloak_container_service.id
}

resource "aws_security_group_rule" "ing_https_tcp" {
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = aws_security_group.keycloak_container_service.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "egress_all_from_ecs" {
  description       = "Allow all outbound traffic by default"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  type              = "egress"
  security_group_id = aws_security_group.keycloak_container_service.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_appautoscaling_target" "ecs_task_count" {
  max_capacity       = var.max_containers
  min_capacity       = var.min_containers
  resource_id        = "service/${aws_ecs_cluster.keycloak_ecs_cluster.name}/${aws_ecs_service.keycloak_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"

}

resource "aws_appautoscaling_policy" "keycloak" {
  policy_type        = "TargetTrackingScaling"
  name               = "keycloakfromnewvpcKeyCloakKeyCloakContainerSerivceServiceTaskCountTargetCpuScaling97B57114"
  resource_id        = aws_appautoscaling_target.ecs_task_count.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  target_tracking_scaling_policy_configuration {
    target_value = var.auto_scaling_target_cpu_utilization

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_lb" "keycloak_ecs_service" {
  name                       = "keycloak-${local.kc_id}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.public_subnets
  tags                       = local.default_tags
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.keycloak_lb_access_logs.bucket
    enabled = true
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "Keycloak ALB"
  vpc_id = var.vpc_id
  tags   = local.default_tags
  ingress {
    description      = "Allow from anyone on port 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "egress_https_tcp" {
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  type                     = "egress"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.keycloak_container_service.id
}

resource "aws_lb_listener" "keycloak_https" {
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  load_balancer_arn = aws_lb.keycloak_ecs_service.arn
  tags              = local.default_tags
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

resource "aws_lb_target_group" "ecs" {
  name        = "Keycloak-ECS"
  port        = 8443
  protocol    = "HTTPS"
  target_type = "ip"
  tags        = local.default_tags
  vpc_id      = var.vpc_id
  slow_start  = 60
  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 604800
  }
}
