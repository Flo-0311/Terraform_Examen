output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "alb_dns_name" {
  description = "DNS Name des Application Load Balancers"
  value       = aws_lb.lb.dns_name
}