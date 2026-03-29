############################################
# Data source für Ubuntu AMI
############################################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################################
# Data source für Availability Zones
############################################
data "aws_availability_zones" "available" {
  state = "available"
}

############################################
# Key Pair
############################################
resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment}-deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

############################################
# Bastion Security Group
############################################
resource "aws_security_group" "bastion" {
  name_prefix = "${var.environment}-bastion-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-bastion-sg"
  }
}

############################################
# Bastion Host
############################################
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name              = aws_key_pair.deployer.key_name
  subnet_id             = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "${var.environment}-bastion-host"
  }
}

############################################
# Web Security Group
############################################
resource "aws_security_group" "web" {
  name_prefix = "${var.environment}-web-"
  vpc_id      = var.vpc_id

  # SSH from Bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # HTTP from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-sg"
  }
}

############################################
# WordPress User Data Script
############################################
locals {
  user_data = base64encode(templatefile("${path.module}/wordpress-install.sh", {
    db_endpoint = var.db_endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  }))
}

############################################
# Launch Template für WordPress
############################################
resource "aws_launch_template" "wordpress" {
  name_prefix   = "${var.environment}-wordpress-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-wordpress-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

############################################
# Auto Scaling Group
############################################
resource "aws_autoscaling_group" "wordpress" {
  name                = "${var.environment}-wordpress-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 1  # Wie gefordert
  max_size         = 2  # Wie gefordert
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-wordpress-asg"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
  }
}
