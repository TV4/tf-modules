resource "aws_ecs_cluster" "KeyCloakKeyCloakContainerSerivceClusterA18E44FF" {
  name = "KeyCloakKeyCloakContainerSerivceClusterA18E44FF"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-role-policy-attach" {
  role       = aws_iam_role.KeyCloakKeyCloakContainerSerivceTaskRole0658CED2.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

resource "aws_iam_role" "KeyCloakKeyCloakContainerSerivceTaskRole0658CED2" {
  name                = "KeyCloakKeyCloakContainerSerivceTaskRole0658CED2"
  managed_policy_arns = [data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn]
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

resource "aws_iam_role_policy" "KeyCloakKeyCloakContainerSerivceTaskRoleDefaultPolicyA2321E87" {
  name = "KeyCloakKeyCloakContainerSerivceTaskRoleDefaultPolicyA2321E87"
  role = aws_iam_role.KeyCloakKeyCloakContainerSerivceTaskRole0658CED2.id
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
        Resource = aws_cloudwatch_log_group.KeyCloakKeyCloakContainerSerivceLogGroup010F2AAE.arn
      },
      #   {
      #     Action = [
      #         "secretsmanager:GetSecretValue",
      #         "secretsmanager:DescribeSecret"
      #     ]
      #     Effect   = "Allow"
      #     Resource = foobar.KeyCloakDatabaseDBClusterSecretAttachment50401C92.arn
      #   },
      #   {
      #     Action = [
      #         "SecretsManager:GetSecretValue",
      #         "secretsmanager:DescribeSecret"
      #     ]
      #     Effect   = "Allow"
      #     Resource = foobar.KeyCloakKCSecretF8498E5C.arn
      #   },
    ]
  })
}

resource "aws_iam_role" "KeyCloakKeyCloakContainerSerivceTaskDefTaskRole0DC4D418" {
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
      },
    ]
  })
}


resource "aws_ecs_task_definition" "KeyCloakKeyCloakContainerSerivceTaskDef30C9533A" {
  family                   = "KeyCloakKeyCloakContainerSerivceTaskDef30C9533A"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.KeyCloakKeyCloakContainerSerivceTaskDefTaskRole0DC4D418.arn
  execution_role_arn       = aws_iam_role.KeyCloakKeyCloakContainerSerivceTaskRole0658CED2.arn
  cpu                      = 4096
  memory                   = 30720

  container_definitions = <<DEFINITION
  [{
		"name": "bootstrap",
		"image": "${local.KeyCloakKeyCloakContainerSerivceBootstrapImage}",
		"essential": false,
    "cpu": 1024,
    "memory": 1024,
		"command": ["sh", "-c", "mysql -u$DB_USER -p$DB_PASSWORD -h$DB_ADDR -e \"CREATE DATABASE IF NOT EXISTS $DB_NAME\""],
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
				"value": "${aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.endpoint}"
			},
      {
			"name": "DB_PASSWORD",
			"value": "${var.db_password}"
		}
		],
		"logConfiguration": {
			"logDriver": "awslogs",
			"options": {
				"awslogs-group": "${aws_cloudwatch_log_group.KeyCloakKeyCloakContainerSerivceLogGroup010F2AAE.name}",
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
		"taskRoleArn": "${aws_iam_role.KeyCloakKeyCloakContainerSerivceTaskDefTaskRole0DC4D418.arn}",
		"executionRole": "${aws_iam_role.KeyCloakKeyCloakContainerSerivceTaskRole0658CED2.arn}",
		"image": "${local.KeyCloakKeyCloakContainerSerivceKeycloakImage}",
		"essential": true,
		"dependsOn": [{
			"condition": "SUCCESS",
			"containerName": "bootstrap"
		}],
		"environment": [{
				"name": "DB_ADDR",
				"value": "${aws_rds_cluster.KeyCloakDatabaseDBCluster06E9C0E1.endpoint}"
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
			}, {
				"name": "DB_PASSWORD",
				"value": "${var.db_password}"
			},
			{
				"name": "KEYCLOAK_USER",
				"value": "${var.keycloak_user}"
			},
			{
				"name": "KEYCLOAK_PASSWORD",
				"value": "${var.keycloak_password}"
			}
		],
		"logConfiguration": {
			"logDriver": "awslogs",
			"options": {
				"awslogs-group": "${aws_cloudwatch_log_group.KeyCloakKeyCloakContainerSerivceLogGroup010F2AAE.name}",
				"awslogs-region": "${data.aws_region.current.name}",
				"awslogs-stream-prefix": "bootstrap"
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
		"Secrets": []
	}
]
  DEFINITION
}

resource "aws_cloudwatch_log_group" "KeyCloakKeyCloakContainerSerivceLogGroup010F2AAE" {
  name = "KeyCloakKeyCloakContainerSerivceLogGroup010F2AAE"

  retention_in_days = 30
  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}


resource "aws_ecs_service" "KeyCloakKeyCloakContainerSerivceService79D3F427" {
  name                               = "KeyCloakKeyCloakContainerSerivceService79D3F427"
  cluster                            = aws_ecs_cluster.KeyCloakKeyCloakContainerSerivceClusterA18E44FF.id
  task_definition                    = aws_ecs_task_definition.KeyCloakKeyCloakContainerSerivceTaskDef30C9533A.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  desired_count                      = var.min_containers
  enable_ecs_managed_tags            = false
  health_check_grace_period_seconds  = 120
  launch_type                        = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ECSTargetGroupCE3EF52C.arn
    container_name   = "keycloak"
    container_port   = 8443
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id]
    subnets = [
      aws_subnet.key_cloak_vpc_private_subnet_1.id,
      aws_subnet.key_cloak_vpc_private_subnet_2.id
    ]
  }

  depends_on = [
    aws_lb_target_group.ECSTargetGroupCE3EF52C,
    aws_lb_listener.KeyCloakKeyCloakContainerSerivceALBHttpsListener140F85B9,

  ]
}

resource "aws_security_group" "KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D" {
  description = "keycloak-from-new-vpc/KeyCloak/KeyCloakContainerSerivce/Service/SecurityGroup"
  vpc_id      = aws_vpc.key_cloak_vpc.id
}

resource "aws_security_group_rule" "ingress7600" {
  description              = "kc jgroups-tcp"
  from_port                = 7600
  to_port                  = 7600
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
  source_security_group_id = aws_security_group.KeyCloakKeyCloakContainerSerivceALBSecurityGroup8F5103C6.id
}

resource "aws_security_group_rule" "ingress57600" {
  description              = "kc jgroups-tcp-fd"
  from_port                = 57600
  to_port                  = 57600
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
  source_security_group_id = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
}

resource "aws_security_group_rule" "ingress55200" {
  description              = "kc jgroups-udp"
  from_port                = 55200
  to_port                  = 55200
  protocol                 = "udp"
  type                     = "ingress"
  security_group_id        = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
  source_security_group_id = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
}

resource "aws_security_group_rule" "ingress54200" {
  description              = "kc jgroups-udp-fd"
  from_port                = 54200
  to_port                  = 54200
  protocol                 = "udp"
  type                     = "ingress"
  security_group_id        = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
  source_security_group_id = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
}

resource "aws_security_group_rule" "ingress8443" {
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
  source_security_group_id = aws_security_group.KeyCloakKeyCloakContainerSerivceALBSecurityGroup8F5103C6.id
}

resource "aws_appautoscaling_target" "KeyCloakKeyCloakContainerSerivceServiceTaskCountTarget0EDF86B3" {
  max_capacity       = var.max_containers
  min_capacity       = var.min_containers
  resource_id        = "service/${aws_ecs_cluster.KeyCloakKeyCloakContainerSerivceClusterA18E44FF.name}/${aws_ecs_service.KeyCloakKeyCloakContainerSerivceService79D3F427.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"

}

resource "aws_appautoscaling_policy" "KeyCloakKeyCloakContainerSerivceServiceTaskCountTargetCpuScaling1480DC0B" {
  policy_type        = "TargetTrackingScaling"
  name               = "keycloakfromnewvpcKeyCloakKeyCloakContainerSerivceServiceTaskCountTargetCpuScaling97B57114"
  resource_id        = aws_appautoscaling_target.KeyCloakKeyCloakContainerSerivceServiceTaskCountTarget0EDF86B3.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  target_tracking_scaling_policy_configuration {
    target_value = var.auto_scaling_target_cpu_utilization

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}


resource "aws_lb" "ContainerSerivceALBE100B67D" {
  name               = "ContainerSerivceALBE100B67D"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.KeyCloakKeyCloakContainerSerivceALBSecurityGroup8F5103C6.id]
  subnets            = [aws_subnet.key_cloak_vpc_public_subnet_1.id, aws_subnet.key_cloak_vpc_public_subnet_2.id]

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  depends_on = [
    aws_route.key_cloak_vpc_public_subnet_1_default_route,
    aws_route.key_cloak_vpc_public_subnet_2_default_route,
  ]
}

resource "aws_security_group" "KeyCloakKeyCloakContainerSerivceALBSecurityGroup8F5103C6" {
  name        = "KeyCloakKeyCloakContainerSerivceALBSecurityGroup8F5103C6"
  description = "Automatically created Security Group for ELB keycloakfromnewvpcKeyCloakKeyCloakContainerSerivceALB6949C8EF"
  vpc_id      = aws_vpc.key_cloak_vpc.id

  ingress {
    description      = "Allow from anyone on port 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "KeyCloakKeyCloakContainerSerivceServiceSecurityGroupfromkeycloakfromnewvpcKeyCloakKeyCloakContainerSerivceALBSecurityGroupFD2CC2BD8443F1CBDED3" {
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  type                     = "egress"
  security_group_id        = aws_security_group.KeyCloakKeyCloakContainerSerivceALBSecurityGroup8F5103C6.id
  source_security_group_id = aws_security_group.KeyCloakKeyCloakContainerSerivceServiceSecurityGroup4C80023D.id
}

resource "aws_lb_listener" "KeyCloakKeyCloakContainerSerivceALBHttpsListener140F85B9" {
  port     = "80"
  protocol = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = var.certificate_arn
  load_balancer_arn = aws_lb.ContainerSerivceALBE100B67D.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ECSTargetGroupCE3EF52C.arn
  }
}

resource "aws_lb_target_group" "ECSTargetGroupCE3EF52C" {
  name        = "ECSTargetGroupCE3EF52C"
  port        = 8443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_vpc.key_cloak_vpc.id
  slow_start  = 60
  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 604800
  }
}
