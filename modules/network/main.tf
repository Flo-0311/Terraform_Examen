#########################
##VPC
#########################

resource "aws_vpc" "main" {
  cidr_block = var.cidr_vpc
  enable_dns_support = true
  enable_dns_hostnames = true
    tags =  {
    Name = "vpc-${var.environment}"
  }
}

#########################
##Public Subnetz
#########################

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "eu-west-3${each.key}" 
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-${each.key}-${var.environment}"
    Environment = var.environment
  }
}

#########################
##Privat Subnetz
#########################

resource "aws_subnet" "privat" {
  for_each = var.privat_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "eu-west-3${each.key}" 

  tags = {
    Name        = "privat-${each.key}-${var.environment}"
    Environment = var.environment
  }
}

#########################
#Inet Gateway
#########################

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "gateway${var.environment}"
  }

  depends_on = [aws_vpc.main]
}

#########################
##Routing Public Subnetworks
#########################

resource "aws_route_table" "rtb_public" {

  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "public-routetable-${var.environment}"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_route" "route_igw" {
  route_table_id = "${aws_route_table.rtb_public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gateway.id}"

depends_on = [aws_internet_gateway.gateway]
}


resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.rtb_public.id
}


#########################
#NAT Gateway 
#########################


resource "aws_eip" "elastic_ip" {
  for_each = var.elastic_ips

  domain = each.value
}


resource "aws_nat_gateway" "nat_gw" {

  for_each = aws_subnet.public
  allocation_id = aws_eip.elastic_ip[each.key].id

  subnet_id = each.value.id

  tags = {
    Name = "nat-${each.key}-${var.environment}"
  }
}



resource "aws_route_table" "rtb_nat" {
  for_each = aws_nat_gateway.nat_gw

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "nat-${each.key}-${var.environment}"
  }
}


resource "aws_route" "route_nat" {

  for_each = aws_nat_gateway.nat_gw

  route_table_id         = aws_route_table.rtb_nat[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.id
}

resource "aws_route_table_association" "rta_subnet_association" {
  for_each = aws_subnet.privat

  subnet_id = each.value.id
  route_table_id         = aws_route_table.rtb_nat[each.key].id
}