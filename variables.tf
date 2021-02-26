variable "ecs_cloudwatch_logs_group_name" {
  description = "Name of the Log Group where ECS logs should be written"
  type        = string
  default     = "/ecs/wordpress"
}

variable "ecs_cluster_name" {
  description = "Name for the ECS cluster"
  type        = string
  default     = "wordpress_cluster"
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

# variable "ecs_service_security_group_ids" {
#   description = "Security groups assigned to the task ENIs"
#   type        = list(string)
#   default     = []
# }

variable "ecs_service_assign_public_ip" {
  description = "Whether to assign a public IP to the task ENIs"
  type        = bool
  default     = false
}

variable "ecs_task_definition_family" {
  description = "Specify a family for a task definition, which allows you to track multiple versions of the same task definition"
  type        = string
  default     = "wordpress-family"
}

variable "ecs_task_definition_cpu" {
  description = "Number of CPU units reserved for the container in powers of 2"
  type        = string
  default     = "1024"
}

variable "ecs_task_definition_memory" {
  description = "Specify a family for a task definition, which allows you to track multiple versions of the same task definition"
  type        = string
  default     = "2048"
}

# variable "efs_service_security_group_ids" {
#   description = "Security groups to assign to the EFS mount target"
#   type        = list(string)
#   default     = []
# }

variable "lb_name" {
  description = "Name for the load balancer"
  type        = string
  default     = "wordpress"
}

variable "lb_internal" {
  description = "If the load balancer should be an internal load balancer"
  type        = bool
  default     = false
}

variable "lb_listener_enable_ssl" {
  description = "Enable the SSL listener, if this is set the lb_listener_certificate_arn must also be provided"
  type        = bool
  default     = false
}

variable "lb_listener_certificate_arn" {
  description = "The ACM certificate ARN to use on the HTTPS listener"
  type        = string
  default     = ""
}

variable "lb_listener_ssl_policy" {
  description = "The SSL policy to apply to the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
}

# variable "lb_security_group_ids" {
#   description = "Security groups to assign to the load balancer"
#   type        = list(string)
#   default     = []
# }

variable "lb_subnet_ids" {
  description = "Subnets where load balancer should be created"
  type        = list(string)
}

variable "lb_target_group_http" {
  description = "Name of the HTTP target group"
  type        = string
  default     = "wordpress-http"
}

variable "lb_target_group_https" {
  description = "Name of the HTTPS target group"
  type        = string
  default     = "wordpress-https"
}

variable "db_subnet_group_name" {
  description = "If an existing DB subnet group exists, provide the name"
  type        = string
  default     = ""
}

variable "db_subnet_group_subnet_ids" {
  description = "Subnets to be used in the db subnet group"
  type        = list(string)
  default     = []
}

variable "rds_cluster_identifier" {
  description = "Name of the RDS cluster"
  type        = string
  default     = "wordpress"
}

variable "rds_cluster_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 1
}

variable "rds_cluster_database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "wordpress"
}

variable "rds_cluster_deletion_protection" {
  description = "If the cluster should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "rds_cluster_enable_cloudwatch_logs_export" {
  description = "Set of log types to export to cloudwatch, valid values are audit, error, general, slowquery, postgresql"
  type        = list(string)
  default     = ["audit"]
}

variable "rds_cluster_engine_version" {
  description = "Engine version to use for the cluster"
  type        = string
  default     = ""
}

variable "rds_cluster_master_username" {
  description = "Master username for the RDS cluster"
  type        = string
  default     = "admin"
}

# variable "rds_cluster_security_group_ids" {
#   description = "Security groups to assign to the RDS instances"
#   type        = list(string)
#   default     = []
# }

variable "rds_cluster_preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.  Time in UTC."
  type        = string
  default     = "08:00-09:00"
}

variable "rds_cluster_preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)."
  type        = string
  default     = "sun:06:00-sun:07:00"
}

variable "rds_cluster_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  type        = bool
  default     = true
}

variable "rds_cluster_instance_count" {
  description = "Number of RDS instances to provision"
  type        = number
  default     = 2
}

variable "rds_cluster_instance_instance_class" {
  description = "Database instance type"
  type        = string
  default     = "db.t3.small"
}

variable "secrets_manager_name" {
  description = "Name of the secrets manager secret"
  type        = string
  default     = "wordpress"
}

variable "security_group_ids" {
  description = "Map of security group id(s) for each service to replace default security groups.  Must provide a definition for all."
  type        = map(list(string))
  default = {
    efs = []
    ecs = []
    lb  = []
    rds = []
  }
}

variable "tags" {
  description = "Map of tags to provide to the resources created"
  type        = map(string)
  default     = {}
}

locals {
  rds_cluster_engine_version     = var.rds_cluster_engine_version == "" ? data.aws_rds_engine_version.rds_engine_version.version : var.rds_cluster_engine_version
  db_subnet_group_name           = var.db_subnet_group_name == "" ? aws_db_subnet_group.db[0].name : var.db_subnet_group_name
  efs_service_security_group_ids = length(var.security_group_ids.efs) == 0 ? aws_security_group.efs_service.*.id : var.security_group_ids.efs
  ecs_service_security_group_ids = length(var.security_group_ids.ecs) == 0 ? aws_security_group.ecs_service.*.id : var.security_group_ids.ecs
  lb_security_group_ids          = length(var.security_group_ids.lb) == 0 ? aws_security_group.lb_service.*.id : var.security_group_ids.lb
  rds_cluster_security_group_ids = length(var.security_group_ids.rds) == 0 ? aws_security_group.rds_cluster.*.id : var.security_group_ids.rds
}
