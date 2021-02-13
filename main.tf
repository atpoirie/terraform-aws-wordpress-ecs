resource "random_password" "db_password" {
  length = 16
  special = false
}

resource "aws_ecs_cluster" "wordpress" {
   name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "wordpress" {
   family = var.ecs_task_definition_family
   container_definitions = data.template_file.wordpress.rendered
   network_mode = "awsvpc"
   requires_compatibilities = [ "FARGATE" ]
   cpu = var.ecs_task_definition_cpu
   memory = var.ecs_task_definition_memory
   execution_role_arn = aws_iam_role.ecs_task_role.arn
   task_role_arn = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_service" "wordpress" {
   name = var.ecs_service_name
   cluster = aws_ecs_cluster.wordpress.arn
   task_definition = aws_ecs_task_definition.wordpress.arn
   desired_count = var.ecs_service_desired_count
   launch_type = "FARGATE"
  #  health_check_grace_period_seconds = 600
   network_configuration {
     subnets = var.ecs_service_subnet_ids
     security_groups = local.ecs_service_security_group_ids
     assign_public_ip = var.ecs_service_assign_public_ip
   }
   load_balancer {
     target_group_arn = aws_lb_target_group.wordpress_http.arn
     container_name = var.ecs_service_container_name
     container_port = "80"
   }
   load_balancer {
     target_group_arn = aws_lb_target_group.wordpress_https.arn
     container_name = var.ecs_service_container_name
     container_port = "443"
   }
}

resource "aws_lb" "wordpress" {
  name = var.lb_name
  internal = var.lb_internal
  load_balancer_type = "application"
  security_groups = local.lb_security_group_ids
  subnets = var.lb_subnet_ids
}

resource "aws_lb_listener" "wordpress_http" {
  load_balancer_arn = aws_lb.wordpress.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.wordpress_http.arn
  }
}

resource "aws_lb_listener" "wordpress_https" {
  load_balancer_arn = aws_lb.wordpress.arn
  port = "443"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.wordpress_https.arn
  }
}

resource "aws_lb_target_group" "wordpress_http" {
  name = var.lb_target_group_http
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = data.aws_subnet.ecs_service_subnet_ids.vpc_id
  health_check {
    matcher = "200-499"
  }
}

resource "aws_lb_target_group" "wordpress_https" {
  name = var.lb_target_group_https
  port = 443
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = data.aws_subnet.ecs_service_subnet_ids.vpc_id
  health_check {
    matcher = "200-499"
  }
}

resource "aws_db_subnet_group" "db" {
  count = var.db_subnet_group_name == "" ? 1 : 0
  name = "wordpress_db_subnet_group"
  subnet_ids = var.db_subnet_group_subnet_ids
}

resource "aws_rds_cluster" "wordpress" {
  cluster_identifier = var.rds_cluster_identifier
  database_name = var.rds_cluster_database_name
  db_subnet_group_name = local.db_subnet_group_name
  engine_version = local.rds_cluster_engine_version
  engine = "aurora-mysql"
  master_password = random_password.db_password.result
  master_username = "admin"
  vpc_security_group_ids = local.rds_cluster_security_group_ids
}

resource "aws_rds_cluster_instance" "wordpress" {
   identifier = var.rds_cluster_identifier
   cluster_identifier = aws_rds_cluster.wordpress.id
   engine = "aurora-mysql"
   engine_version = local.rds_cluster_engine_version
   instance_class = var.rds_cluster_instance_instance_class
   db_subnet_group_name = local.db_subnet_group_name
}