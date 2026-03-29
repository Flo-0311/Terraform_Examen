############################################
# DB Subnet Group
############################################
resource "aws_db_subnet_group" "wordpress" {
  name       = "${var.environment}-wordpress-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.environment}-wordpress-db-subnet-group"
  }
}

############################################
# Database Security Group
############################################
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.web_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-rds-sg"
  }
}

############################################
# RDS Instance
############################################
resource "aws_db_instance" "wordpress" {
  identifier = "${var.environment}-wordpress-db"
  
  # Engine Configuration
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  # Storage Configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  storage_encrypted    = true
  
  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  
  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az              = false  # High Availability in 2 AZs
  
  # Backup Configuration
  backup_retention_period = 0
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Other Configuration
  skip_final_snapshot = true
  deletion_protection = false
  
  tags = {
    Name = "${var.environment}-wordpress-db"
  }
}