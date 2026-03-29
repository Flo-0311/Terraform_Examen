output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.wordpress.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.wordpress.db_name
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.wordpress.username
  sensitive   = true
}


output "db_password" {
  description = "Database password"
  value       = var.db_password
  sensitive   = true
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.rds.id
}


output "db_port" {
  description = "Database port"
  value       = aws_db_instance.wordpress.port
}
