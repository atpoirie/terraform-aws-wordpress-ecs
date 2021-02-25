output "lb_dns_name" {
  value = aws_lb.wordpress.dns_name
}

output "rds_cluster_endpoint" {
  value = aws_rds_cluster.wordpress.endpoint
}

output "efs_id" {
  value = aws_efs_file_system.wordpress.id
}


