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



resource "aws_subnet" "private_subnet" {
  for_each = {
    a = {
      cidr = var.private_subnet_a[0]
      az   = var.az_a
    }
    b = {
      cidr = var.private_subnet_b[0]
      az   = var.az_b
    }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name        = "private_subnet_${each.key}_${var.environment}"
    Environment = var.environment
  }
}



############################################
#Internet gateway
############################################

resource "aws_internet_gateway" "gw" {
    vpc_id = var.aws_vpc.main.id

    tags = {
        Name = "main"
    }
}

############################################
#Routing Table for Public Subnetz -> IGW -> Internet
############################################

resource "aws_route_table" "rtb_public" {
    vpc_id = var.aws_vpc.main.id

    tage = {
        Name = "public-routetable"
    }

    depends_on = [aws_vpc.main]
}

resource "aws_route" "route_igw" {
    route_table_id = "${aws_route_table.rtb_public.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
    
    depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table_association" "rta_subnet_association_puba" {
    subnet_id = "${aws_subnet.public_subnet_a.id}
    route_table_id = "${aws_route_table.rtb_public.id}"

    depends_on = [aws_route_table.rtb_public]
}


resource "aws_route_table_association" "rta_subnet_association_puba" {
    subnet_id = "${aws_subnet.public_subnet_b.id}
    route_table_id = "${aws_route_table.rtb_public.id}"

    depends_on = [aws_route_table.rtb_public]
}