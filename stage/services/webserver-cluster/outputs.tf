output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.webserver-cluster.alb_dns_name
}
