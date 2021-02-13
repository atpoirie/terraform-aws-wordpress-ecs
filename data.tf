data "template_file" "wordpress" {
  template = "${file("${path.module}/wordpress.tpl")}"
  vars = {
    ecs_service_container_name = var.ecs_service_container_name
    wordpress_db_host          = aws_rds_cluster.wordpress.endpoint
    wordpress_db_user          = var.aws_rds_cluster_master_username
    aws_region                 = data.aws_region.current.name
    aws_logs_group             = var.ecs_cloudwatch_logs_group
    aws_account_id             = data.aws_caller_identity.current.account_id
    secret_name                = aws_secretsmanager_secret.wordpress.name
  }
}

data "aws_rds_engine_version" "rds_engine_version" {
  engine = "aurora-mysql"
}

data "aws_subnet" "ecs_service_subnet_ids" {
  id = var.ecs_service_subnet_ids[0]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}