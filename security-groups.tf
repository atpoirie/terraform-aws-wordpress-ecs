resource "aws_security_group" "ecs_service" {
  count       = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  name        = "wordpress-ecs-service"
  description = "wordpress ecs service"
  vpc_id      = data.aws_subnet.ecs_service_subnet_ids.vpc_id
}

resource "aws_security_group_rule" "ecs_service_ingress_http" {
  count                    = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type                     = "ingress"
  description              = "http from load balancer"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.lb_security_group_ids[0]
  security_group_id        = aws_security_group.ecs_service[0].id
}

resource "aws_security_group_rule" "ecs_service_ingress_https" {
  count                    = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type                     = "ingress"
  description              = "https from load balancer"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = local.lb_security_group_ids[0]
  security_group_id        = aws_security_group.ecs_service[0].id
}

resource "aws_security_group_rule" "ecs_service_egress_http" {
  count             = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type              = "egress"
  description       = "http to internet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service[0].id
}

resource "aws_security_group_rule" "ecs_service_egress_https" {
  count             = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type              = "egress"
  description       = "https to internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service[0].id
}

resource "aws_security_group_rule" "ecs_service_egress_mysql" {
  count                    = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type                     = "egress"
  description              = "mysql"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = local.rds_cluster_security_group_ids[0]
  security_group_id        = aws_security_group.ecs_service[0].id
}


resource "aws_security_group" "lb_service" {
  count       = length(var.lb_security_group_ids) == 0 ? 1 : 0
  name        = "wordpress-lb-service"
  description = "wordpress lb service"
  vpc_id      = data.aws_subnet.ecs_service_subnet_ids.vpc_id
}

resource "aws_security_group_rule" "lb_service_ingress_http" {
  count             = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type              = "ingress"
  description       = "http"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_service[0].id
}

resource "aws_security_group_rule" "lb_service_ingress_https" {
  count             = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type              = "ingress"
  description       = "http"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_service[0].id
}

resource "aws_security_group_rule" "lb_service_egress_http" {
  count                    = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type                     = "egress"
  description              = "http"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.ecs_service_security_group_ids[0]
  security_group_id        = aws_security_group.lb_service[0].id
}

resource "aws_security_group_rule" "lb_service_egress_https" {
  count                    = length(var.ecs_service_security_group_ids) == 0 ? 1 : 0
  type                     = "egress"
  description              = "https"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = local.ecs_service_security_group_ids[0]
  security_group_id        = aws_security_group.lb_service[0].id
}

resource "aws_security_group" "rds_cluster" {
  count       = length(var.rds_cluster_security_group_ids) == 0 ? 1 : 0
  name        = "wordpress-rds-service"
  description = "wordpress rds service"
  vpc_id      = data.aws_subnet.ecs_service_subnet_ids.vpc_id
}

resource "aws_security_group_rule" "rds_cluster_ingress_mysql" {
  count                    = length(var.rds_cluster_security_group_ids) == 0 ? 1 : 0
  type                     = "ingress"
  description              = "mysql"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = local.ecs_service_security_group_ids[0]
  security_group_id        = aws_security_group.rds_cluster[0].id
}