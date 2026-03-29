###############################################
# VPC
###############################################
resource "aws_vpc" "main" {
    cidr_block           = var.cidr_vpc
    enable_dns_support   = true
    enable_dns_hostnames = true
    
    tags = {
        Name        = "${var.environment}-vpc"
        Environment = var.environment
    }
}

###############################################
# Public Subnets
###############################################
resource "aws_subnet" "public_subnet_a" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_a[0]
    map_public_ip_on_launch = true
    availability_zone       = var.az_a

    tags = {
        Name        = "public_subnet_a_${var.environment}"
        Environment = var.environment
        Type        = "Public"
    }

    depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_b" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_b[0]
    map_public_ip_on_launch = true
    availability_zone       = var.az_b

    tags = {
        Name        = "public_subnet_b_${var.environment}"
        Environment = var.environment
        Type        = "Public"
    }

    depends_on = [aws_vpc.main]
}

###############################################
# Private Subnets
###############################################
resource "aws_subnet" "privat_subnet_a" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.privat_subnet_a[0]
    availability_zone = var.az_a

    tags = {
        Name        = "private_subnet_a_${var.environment}"
        Environment = var.environment
        Type        = "Private"
    }
}

resource "aws_subnet" "privat_subnet_b" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.privat_subnet_b[0]
    availability_zone = var.az_b

    tags = {
        Name        = "private_subnet_b_${var.environment}"
        Environment = var.environment
        Type        = "Private"
    }
}

############################################
# Internet Gateway
############################################
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name        = "${var.environment}-igw"
        Environment = var.environment
    }
}

############################################
# Elastic IPs for NAT Gateways
############################################
resource "aws_eip" "nat_a" {
    domain = "vpc"
    
    tags = {
        Name        = "${var.environment}-eip-nat-a"
        Environment = var.environment
    }
    
    depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "nat_b" {
    domain = "vpc"
    
    tags = {
        Name        = "${var.environment}-eip-nat-b"
        Environment = var.environment
    }
    
    depends_on = [aws_internet_gateway.gw]
}

############################################
# NAT Gateway A
############################################
resource "aws_nat_gateway" "nat_public_a" {
    allocation_id = aws_eip.nat_a.id
    subnet_id     = aws_subnet.public_subnet_a.id

    tags = {
        Name        = "${var.environment}-nat-gateway-a"
        Environment = var.environment
    }
    
    depends_on = [aws_internet_gateway.gw]
}

############################################
# NAT Gateway B
############################################
resource "aws_nat_gateway" "nat_public_b" {
    allocation_id = aws_eip.nat_b.id
    subnet_id     = aws_subnet.public_subnet_b.id

    tags = {
        Name        = "${var.environment}-nat-gateway-b"
        Environment = var.environment
    }
    
    depends_on = [aws_internet_gateway.gw]
}

############################################
# Public Route Table
############################################
resource "aws_route_table" "rtb_public" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name        = "${var.environment}-public-rt"
        Environment = var.environment
        Type        = "Public"
    }

    depends_on = [aws_vpc.main]
}

resource "aws_route" "route_igw" {
    route_table_id         = aws_route_table.rtb_public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gw.id

    depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table_association" "rta_subnet_association_puba" {
    subnet_id      = aws_subnet.public_subnet_a.id
    route_table_id = aws_route_table.rtb_public.id

    depends_on = [aws_route_table.rtb_public]
}

resource "aws_route_table_association" "rta_subnet_association_pubb" {
    subnet_id      = aws_subnet.public_subnet_b.id
    route_table_id = aws_route_table.rtb_public.id

    depends_on = [aws_route_table.rtb_public]
}

############################################
# Private Route Table A (for NAT Gateway A)
############################################
resource "aws_route_table" "nat_public_a" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name        = "${var.environment}-private-rt-a"
        Environment = var.environment
        Type        = "Private"
    }

    depends_on = [aws_vpc.main]
}

resource "aws_route" "route_nat_a" {
    route_table_id         = aws_route_table.nat_public_a.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_public_a.id

    depends_on = [aws_nat_gateway.nat_public_a]
}

resource "aws_route_table_association" "rta_nat_a_association" {
    subnet_id      = aws_subnet.privat_subnet_a.id
    route_table_id = aws_route_table.nat_public_a.id
}

############################################
# Private Route Table B (for NAT Gateway B)
############################################
resource "aws_route_table" "nat_public_b" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name        = "${var.environment}-private-rt-b"
        Environment = var.environment
        Type        = "Private"
    }

    depends_on = [aws_vpc.main]
}

resource "aws_route" "route_nat_b" {
    route_table_id         = aws_route_table.nat_public_b.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_public_b.id

    depends_on = [aws_nat_gateway.nat_public_b]
}

resource "aws_route_table_association" "rta_nat_b_association" {
    subnet_id      = aws_subnet.privat_subnet_b.id
    route_table_id = aws_route_table.nat_public_b.id
}
