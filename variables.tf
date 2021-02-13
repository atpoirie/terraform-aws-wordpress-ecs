variable "ecs_cluster_name" {
  description = "Name for the ECS cluster"
  type = string
  default = "wordpress_cluster"
}

variable "ecs_service_container_name" {
  description = "Container name for the container definition and Target Group association"
  type        = string
  default     = "wordpress"
}

variable "ecs_service_name" {
  description = "Name for the ECS Service"
  type        = string
  default     = "wordpress"
}

variable "ecs_service_desired_count" {
  description = "Number of tasks to have running"
  type        = number
  default     = 2
}

variable "ecs_service_subnet_ids" {
  description = "Subnet ids where ENIs are created for tasks"
  type        = list(string)
}

variable "ecs_service_security_group_ids" {
  description = "Security groups assigned to the task ENIs"
  type        = list(string)
  default = []
}

variable "ecs_service_assign_public_ip" {
  description = "Whether to assign a public IP to the task ENIs"
  type        = bool
  default     = false
}

variable "ecs_task_definition_family" {
  description = "Specify a family for a task definition, which allows you to track multiple versions of the same task definition"
  type = string
  default = "wordpress-family"
}

variable "ecs_task_definition_cpu" {
  description = "Number of CPU units reserved for the container in powers of 2"
  type = string
  default = "1024"
}

variable "ecs_task_definition_memory" {
  description = "Specify a family for a task definition, which allows you to track multiple versions of the same task definition"
  type = string
  default = "2048"
}

variable "lb_name" {
  description = "Name for the load balancer"
  type = string
  default = "wordpress"
}

variable "lb_internal" {
  description = "If the load balancer should be an internal load balancer"
  type = bool
  default = false
}

variable "lb_security_group_ids" {
  description = "Security groups to assign to the load balancer"
  type = list(string)
  default = []
}

variable "lb_subnet_ids" {
  description = "Subnets where load balancer should be created"
  type = list(string)
}

variable "lb_target_group_http" {
  description = "Name of the HTTP target group"
  type = string
  default = "wordpress-http"
}

variable "lb_target_group_https" {
  description = "Name of the HTTPS target group"
  type = string
  default = "wordpress-https"
}

variable "db_subnet_group_name" {
  description = "If an existing DB subnet group exists, provide the name"
  type = string
  default = ""
}

variable "db_subnet_group_subnet_ids" {
  description = "Subnets to be used in the db subnet group"
  type = list(string)
  default = []
}

variable "rds_cluster_identifier" {
  description = "Name of the RDS cluster"
  type = string
  default = "wordpress"
}

variable "rds_cluster_database_name" {
  description = "Name of the database to create"
  type = string
  default = "wordpress"
}

variable "rds_cluster_engine_version" {
  description = "Engine version to use for the cluster"
  type = string
  default = ""
}

variable "rds_cluster_security_group_ids" {
  description = "Security groups to assign to the RDS instances"
  type = list(string)
  default = []
}

variable "rds_cluster_instance_instance_class" {
  description = "Database instance type"
  type = string
  default = "db.t3.small"
}

locals {
  rds_cluster_engine_version = var.rds_cluster_engine_version == "" ?  data.aws_rds_engine_version.rds_engine_version.version : var.rds_cluster_engine_version
  db_subnet_group_name = var.db_subnet_group_name == "" ? aws_db_subnet_group.db[0].name : var.db_subnet_group_name
  ecs_service_security_group_ids = length(var.ecs_service_security_group_ids) == 0 ? aws_security_group.ecs_service.*.id : var.ecs_service_security_group_ids
  lb_security_group_ids = length(var.lb_security_group_ids) == 0 ? aws_security_group.lb_service.*.id : var.lb_security_group_ids
  rds_cluster_security_group_ids = length(var.rds_cluster_security_group_ids) == 0 ? aws_security_group.rds_cluster.*.id : var.rds_cluster_security_group_ids
}