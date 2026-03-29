output "vpc_id" {
  description = "ID from VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = var.cidr_vpc  
}

output "private_subnet_ids" {
  description = "ID from privat subnet"
  value       = [
    aws_subnet.privat_subnet_a.id,
    aws_subnet.privat_subnet_b.id
  ]
}

output "public_subnet_ids" {
  description = "ID from public subnet"
  value       = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]
}

output "nat_gateway_a_ip" {
  description = "Elastic ip from nat gatway a"
  value       = aws_eip.nat_a.public_ip
}

output "nat_gateway_b_ip" {
  description = "Elastic ip from nat gatway b"
  value       = aws_eip.nat_b.public_ip
}

output "internet_gateway_id" {
  description = "id from internet gateway"
  value       = aws_internet_gateway.gw.id
}
