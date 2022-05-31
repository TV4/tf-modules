resource "aws_ecs_cluster" "keycloak_ecs_cluster" {
  name = "keycloak_ecs_cluster"
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


resource "aws_ecs_task_definition" "keycloak_task_definition" {
  tags                     = local.default_tags
  family                   = "keycloak_task_definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.keycloak_container_service_task_role.arn
  execution_role_arn       = aws_iam_role.keycloak_container_service_task_execution_role.arn
  cpu                      = 4096
  memory                   = 30720

  container_definitions = <<DEFINITION
  [{
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
				"value": "keycloak"
			},
			{
				"name": "DB_USER",
				"value": "admin"
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
		"cpu": 3068,
		"memory": 29696,
		"networkMode": "awsvpc",
		"requiredCapabilities": "FARGATE",
		"image": "${local.keycloak_image}",
		"essential": true,
		"dependsOn": [{
			"condition": "SUCCESS",
			"containerName": "bootstrap"
		}],
    "secrets": [
      {
        "name": "KEYCLOAK_PASSWORD",
        "valueFrom": "${var.keycloak_password_secret_arn}"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${var.db_password_secret_arn}"
      }
    ],
		"environment": [{
				"name": "DB_ADDR",
				"value": "${aws_rds_cluster.db_cluster.endpoint}"
			},
			{
				"name": "DB_DATABASE",
				"value": "keycloak"
			},
			{
				"name": "DB_PORT",
				"value": "3306"
			},
			{
				"name": "DB_USER",
				"value": "admin"
			},
			{
				"name": "DB_VENDOR",
				"value": "mysql"
			},
			{
				"name": "JDBC_PARAMS",
				"value": "useSSL=false"
			},
			{
				"name": "JGROUPS_DISCOVERY_PROTOCOL",
				"value": "JDBC_PING"
			},
			{
				"name": "JAVA_OPTS",
				"value": "${var.java_opts}"
			},
			{
				"name": "KEYCLOAK_USER",
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
		]
	}
]
  DEFINITION
}

resource "aws_cloudwatch_log_group" "keycloak_ecs_service" {
  name              = "keycloak_ecs_service"
  retention_in_days = 30
  tags              = local.default_tags
}


resource "aws_ecs_service" "keycloak_ecs_service" {
  name                               = "keycloak_ecs_service"
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
    subnets = var.private_subnets
  }

  depends_on = [
    aws_lb_target_group.ecs,
    aws_lb_listener.keycloak_https,

  ]
}

resource "aws_security_group" "keycloak_container_service" {
  description = "Keycloak ECS Service"
  vpc_id      = var.vpc_id
  tags        = local.default_tags
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
  name                       = "key-cloak-ecs-service"
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
