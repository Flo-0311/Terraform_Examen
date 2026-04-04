output "bastion_public_ip" {
  description = "Public IP des Bastion Hosts für SSH Zugriff"
  value       = aws_instance.bastion.public_ip
}

output "sg_80" {
    value = aws_security_group.sg_80.id
}