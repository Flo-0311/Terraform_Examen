output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}

output "web_security_group_id" {
  description = "Security group ID for web servers"
  value       = aws_security_group.web.id
}

output "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  value       = aws_security_group.bastion.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.wordpress.id
}

output "key_pair_name" {
  description = "Name of the EC2 key pair"
  value       = aws_key_pair.deployer.key_name
}
