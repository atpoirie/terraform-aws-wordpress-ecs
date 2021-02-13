data "template_file" "wordpress" {
   template = "${file("${path.module}/wordpress.tpl")}"
   vars = {
      ecs_service_container_name = var.ecs_service_container_name
      wordpress_db_host = aws_rds_cluster.wordpress.endpoint
      wordpress_db_user = "admin"
      wordpress_db_pass = random_password.db_password.result
      aws_region = data.aws_region.current.name
   }
}

data "aws_rds_engine_version" "rds_engine_version" {
  engine = "aurora-mysql"
}

data "aws_subnet" "ecs_service_subnet_ids" {
   id = var.ecs_service_subnet_ids[0]
}

data "aws_region" "current" {}