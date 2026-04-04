#########################
#Security Group
#########################

resource "aws_security_group" "sg_3306" {

    vpc_id = var.vpc_id

    tags = {
        Name = "sg_3306-${var.environment}"
    }

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [var.sg_80]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.wildcard]
  }

}

#########################
#Subnet Group RDS
#########################

resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group-${var.environment}"
  subnet_ids = [var.privat_ids["a"], var.privat_ids["b"]]

  tags = {
    Name = "My DB subnet group"
  }
}

#########################
#Database Engine
#########################

resource "aws_db_instance" "database" {
  allocated_storage    = 20
  db_name              = var.db_name
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_3306.id]
  publicly_accessible = false
}



