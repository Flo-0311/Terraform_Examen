
#########################
#Securtiy Group
#########################


resource "aws_security_group" "sg_lb" {

    vpc_id = var.vpc_id

    tags = {
        Name = "sg_lb-${var.environment}"
    }

    ingress { 
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [var.wildcard]
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
#Target Group
#########################

resource "aws_lb_target_group" "target_group" {
  name     = "target-group-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "target_group${var.environment}"
  }
}


#########################
#Target Listener
#########################

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}


#########################
#Loadbalancer
#########################

resource "aws_lb" "lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    var.subnet_ids["a"],
    var.subnet_ids["b"]
  ]

  security_groups = [aws_security_group.sg_lb.id]

  enable_deletion_protection = false

  tags = {
    Name = "alb-${var.environment}"
  }
}
