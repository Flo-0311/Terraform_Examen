###############################################
#VPC
###############################################
resource "aws_vpc" "main" {
    cidr_block = var.cidr_vpc
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "Liora_Examen"
    }
}

###############################################
#Subnetz
###############################################
resource "aws_subnet" "public_subnet_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_a[0]
    map_public_ip_on_launch = "true"
    availability_zone = var.az_a

    tags = {
        Name = "public_subnet_a${var.environment}
        Environment = var.environment
    }

    depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_b[0]
    map_public_ip_on_launch = "true"
    availability_zone = var.az_b

        tags = {
        Name = "public_subnet_a${var.environment}
        Environment = var.environment
    }

    depends_on = [aws_vpc.main]
}



resource "aws_subnet" "privat_subnet_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.privat_subnet_a[0]
    availability_zone = var.az_a

       tags = {
        Name = "public_subnet_a${var.environment}
        Environment = var.environment
    }

    depends_on = [aws_vpc.main]
}

resource "aws_subnet" "privat_subnet_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.privat_subnet_b[0]
    availability_zone = var.az_b

       tags = {
        Name = "public_subnet_a${var.environment}
        Environment = var.environment
    }

    depends_on = [aws_vpc.main]
}



############################################
#Routing Table
############################################

