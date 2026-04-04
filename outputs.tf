output "vpc_id" {
  value = module.network.vpc_id
}

output "loadbalancer_dns" {
  value = module.loadbalancer.alb_dns_name
}

