#########################
#Bastion-Key 
#########################


resource "aws_key_pair" "deployer" {
    key_name = "deployer_key"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
}


#########################
#AMI
#########################

data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



#########################
#Bastion-Security Group 
#########################

resource "aws_security_group" "sg_22" {

    vpc_id = var.vpc_id

    tags = {
        Name = "sg_2-${var.environment}"
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.wildcard]
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = [var.wildcard]
  }

}


#########################
#Bastion-Security Instance 
#########################


resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.deployer.key_name
  subnet_id = var.subnet_ids["a"]
  vpc_security_group_ids = [aws_security_group.sg_22.id]
  tags = {
    Name = "bastion-${var.environment}"
  }

}


#########################
#Security Group - Web Apps
#########################



resource "aws_security_group" "sg_80" {

    vpc_id = var.vpc_id

    tags = {
        Name = "sg_80-${var.environment}"
    }

    ingress { #SSH Zugriff für den Bastion Server
      from_port = 22
      to_port = 22
      protocol = "tcp"
      security_groups = [aws_security_group.sg_22.id]
    }

    ingress { #HTTP Zugriff von loadbalancer
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

          # Optional HTTPS 
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [var.wildcard]
  }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.wildcard]
  }

}



#########################
#Web-apps Launch template
#########################


resource "aws_launch_template" "web_template" {
  name_prefix   = "web-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.sg_80.id]  # WICHTIG: vpc_security_group_ids statt security_groups

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2 mysql-client php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc

              # Download WordPress
              cd /tmp
              wget https://wordpress.org/latest.tar.gz
              tar xzf latest.tar.gz
              cp -R wordpress/* /var/www/html/
              rm /var/www/html/index.html

              # WordPress Configuration
              cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
              sed -i "s/database_name_here/${var.db_name}/" /var/www/html/wp-config.php
              sed -i "s/username_here/${var.db_username}/" /var/www/html/wp-config.php
              sed -i "s/password_here/${var.db_password}/" /var/www/html/wp-config.php
              sed -i "s/localhost/${var.db_endpoint}/" /var/www/html/wp-config.php

              # Set permissions
              chown -R www-data:www-data /var/www/html/
              chmod -R 755 /var/www/html/

              # Start Apache
              systemctl enable apache2
              systemctl start apache2
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server-${var.environment}"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}



#########################
#Auto-Scalling Group 
#########################



resource "aws_autoscaling_group" "web-apps" {
  name                      = "web-apps${var.environment}"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300 #Warte 300 Sekunden, bevor Health Checks starten
  health_check_type         = "ELB" #EC 2 Prüft nur die Instanz an sich nict die App / ELB prüft nur wenn man ein Loadbalancer hat (prüft webapp)
  desired_capacity          = 1 #Anzahl der Instanzen, die aktuell laufen sollen
  force_delete              = true #Lösch die Resource sofort – egal ob noch Instanzen laufen.
  vpc_zone_identifier       = [var.private_subnet_ids["a"], var.private_subnet_ids["b"]] #Private Subnet IDs hinzufügen
  target_group_arns = [var.target_group_arn]
  launch_template {
  id      = aws_launch_template.web_template.id
  version = "$Latest"
}

  lifecycle {
    create_before_destroy = true
  }
 
}

