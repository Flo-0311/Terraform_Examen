output "website_url" {
  description = "WordPress website URL"
  value       = "http://${module.loadbalancer.alb_dns_name}"
}

output "bastion_ip" {
  description = "Bastion host public IP"
  value       = module.compute.bastion_public_ip
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}