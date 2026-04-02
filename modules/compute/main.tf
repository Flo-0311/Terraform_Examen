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
        protocol = "-1"
        cidr_blocks = var.wildcard
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "t-1"
        cidr_blocks = var.wildcard
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

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = var.var_cidr
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = var.wildcard
  }

}








#########################
#Web-apps 
#########################


resource "aws_launch_configuration" "template" {
  name_prefix          = "web-config-"
  image_id             = aws_ami.ubuntu.id
  instance_type        = "t3.micro"
  key_name = aws_key_pair.deployer.key_name

  security_groups      = [aws_security_group.web.id]

  
  # User Data für App-Installation
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF

  # Lifecycle für Updates
  lifecycle {
    create_before_destroy = true
  }
}


#########################
#Auto-Scalling Group 
#########################



resource "aws_autoscaling_group" "web-apps" {
  name                      = "web-apps${env.environment}"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.template.name
  vpc_zone_identifier       = [aws_subnet.example1.id, aws_subnet.example2.id]
3
  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  initial_lifecycle_hook {
    name                 = "foobar"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = jsonencode({
      foo = "bar"
    })

    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}