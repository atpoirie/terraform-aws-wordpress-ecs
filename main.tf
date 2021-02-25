resource "random_password" "db_password" {
  length  = 16
  special = false
}

resource "aws_kms_key" "wordpress" {
  description             = "KMS Key used to encrypt Wordpress related resources"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = var.tags
}

resource "aws_kms_alias" "wordpress" {
  name          = "alias/wordpress"
  target_key_id = aws_kms_key.wordpress.id
}

resource "aws_efs_file_system" "wordpress" {
  creation_token = "wordpress"
  encrypted      = true
  kms_key_id     = aws_kms_key.wordpress.arn
  tags           = var.tags
}

resource "aws_efs_mount_target" "wordpress" {
  count           = length(var.ecs_service_subnet_ids)
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = var.ecs_service_subnet_ids[count.index]
  security_groups = local.efs_service_security_group_ids
}

resource "aws_efs_access_point" "wordpress_plugins" {
  file_system_id = aws_efs_file_system.wordpress.id
  posix_user {
    gid = 33
    uid = 33
  }
  root_directory {
    path = "/plugins"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = 755
    }
  }
}

resource "aws_efs_access_point" "wordpress_themes" {
  file_system_id = aws_efs_file_system.wordpress.id
  posix_user {
    gid = 33
    uid = 33
  }
  root_directory {
    path = "/themes"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = 755
    }
  }
}

resource "aws_cloudwatch_log_group" "wordpress" {
  name              = var.ecs_cloudwatch_logs_group_name
  retention_in_days = 14
  kms_key_id        = aws_kms_key.wordpress.arn
  tags              = var.tags
}

resource "aws_ecs_cluster" "wordpress" {
  name = var.ecs_cluster_name
  tags = var.tags
}

resource "aws_ecs_task_definition" "wordpress" {
  family = var.ecs_task_definition_family
  container_definitions = templatefile(
    "${path.module}/wordpress.tpl",
    {
      ecs_service_container_name = var.ecs_service_container_name
      wordpress_db_host          = aws_rds_cluster.wordpress.endpoint
      wordpress_db_user          = var.rds_cluster_master_username
      wordpress_db_name          = var.rds_cluster_database_name
      aws_region                 = data.aws_region.current.name
      aws_logs_group             = aws_cloudwatch_log_group.wordpress.name
      aws_account_id             = data.aws_caller_identity.current.account_id
      secret_name                = aws_secretsmanager_secret.wordpress.name
      cloudwatch_log_group       = var.ecs_cloudwatch_logs_group_name
    }
  )
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_definition_cpu
  memory                   = var.ecs_task_definition_memory
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  volume {
    name = "efs-themes"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.wordpress.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.wordpress_themes.id
      }
    }
  }
  volume {
    name = "efs-plugins"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.wordpress.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.wordpress_plugins.id
      }
    }
  }
  tags = var.tags
}

resource "aws_ecs_service" "wordpress" {
  name             = var.ecs_service_name
  cluster          = aws_ecs_cluster.wordpress.arn
  task_definition  = aws_ecs_task_definition.wordpress.arn
  desired_count    = var.ecs_service_desired_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  propagate_tags   = "SERVICE"
  network_configuration {
    subnets          = var.ecs_service_subnet_ids
    security_groups  = local.ecs_service_security_group_ids
    assign_public_ip = var.ecs_service_assign_public_ip
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.wordpress_http.arn
    container_name   = var.ecs_service_container_name
    container_port   = "80"
  }
  tags = var.tags
}

resource "aws_lb" "wordpress" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = "application"
  security_groups    = local.lb_security_group_ids
  subnets            = var.lb_subnet_ids
  tags               = var.tags
}

resource "aws_lb_listener" "wordpress_http" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_http.arn
  }
}

resource "aws_lb_listener" "wordpress_https" {
  count             = var.lb_listener_enable_ssl ? 1 : 0
  certificate_arn   = var.lb_listener_certificate_arn
  load_balancer_arn = aws_lb.wordpress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.lb_listener_ssl_policy
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_http.arn
  }
}

resource "aws_lb_target_group" "wordpress_http" {
  name        = var.lb_target_group_http
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_subnet.ecs_service_subnet_ids.vpc_id
  health_check {
    matcher = "200-499"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
  tags = var.tags
}

resource "aws_db_subnet_group" "db" {
  count      = var.db_subnet_group_name == "" ? 1 : 0
  name       = "wordpress_db_subnet_group"
  subnet_ids = var.db_subnet_group_subnet_ids
  tags       = var.tags
}

resource "aws_rds_cluster" "wordpress" {
  cluster_identifier              = var.rds_cluster_identifier
  backup_retention_period         = var.rds_cluster_backup_retention_period
  copy_tags_to_snapshot           = true
  database_name                   = var.rds_cluster_database_name
  db_subnet_group_name            = local.db_subnet_group_name
  deletion_protection             = var.rds_cluster_deletion_protection
  enabled_cloudwatch_logs_exports = var.rds_cluster_enable_cloudwatch_logs_export
  engine_version                  = local.rds_cluster_engine_version
  engine                          = "aurora-mysql"
  final_snapshot_identifier       = var.rds_cluster_identifier
  kms_key_id                      = aws_kms_key.wordpress.arn
  master_password                 = random_password.db_password.result
  master_username                 = var.rds_cluster_master_username
  preferred_backup_window         = var.rds_cluster_preferred_backup_window
  preferred_maintenance_window    = var.rds_cluster_preferred_maintenance_window
  storage_encrypted               = true
  skip_final_snapshot             = var.rds_cluster_skip_final_snapshot
  vpc_security_group_ids          = local.rds_cluster_security_group_ids
  tags                            = var.tags
}

resource "aws_rds_cluster_instance" "wordpress" {
  count                = var.rds_cluster_instance_count
  identifier           = join("-", [var.rds_cluster_identifier, count.index])
  cluster_identifier   = aws_rds_cluster.wordpress.id
  engine               = aws_rds_cluster.wordpress.engine
  engine_version       = aws_rds_cluster.wordpress.engine_version
  instance_class       = var.rds_cluster_instance_instance_class
  db_subnet_group_name = local.db_subnet_group_name

  tags = var.tags
}

resource "aws_secretsmanager_secret" "wordpress" {
  name_prefix = var.secrets_manager_name
  description = "Secrets for ECS Wordpress"
  kms_key_id  = aws_kms_key.wordpress.id
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "wordpress" {
  secret_id = aws_secretsmanager_secret.wordpress.id
  secret_string = jsonencode({
    WORDPRESS_DB_HOST     = aws_rds_cluster.wordpress.endpoint
    WORDPRESS_DB_USER     = var.rds_cluster_master_username
    WORDPRESS_DB_PASSWORD = random_password.db_password.result
    WORDPRESS_DB_NAME     = var.rds_cluster_database_name
  })
}
