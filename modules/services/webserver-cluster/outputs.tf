output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.cluster_alb.dns_name
}

output "autoscaling_group_name" {
  description = "Name of the ASG"
  value       = aws_autoscaling_group.cluster_asg.name
}
