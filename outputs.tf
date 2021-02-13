output "lb_dns_name" {
   value = aws_lb.wordpress.dns_name
}

output "lb_zone_id" {
   value = aws_lb.wordpress.zone_id
}
output "rds_cluster_endpoint" {
   value = aws_rds_cluster.wordpress.endpoint
}

