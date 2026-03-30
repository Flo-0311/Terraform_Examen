output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = {
    for k, subnet in aws_subnet.public : k => subnet.id
  }
}