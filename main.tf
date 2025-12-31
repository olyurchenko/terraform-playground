provider "aws" {
  region = "us-east-2"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ami" {
  type = string
  default = "ami-0503ed50b531cc445"
}

variable "port" {
  type = number
  default = 80
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_launch_configuration" "example" {
  instance_type = var.instance_type
  image_id = var.ami
  lifecycle {
    create_before_destroy = true
  }
  security_groups = [aws_security_group.allow_http.id]
  user_data = <<EOF
#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "Hello, World!" > /var/www/html/index.html
EOF
}

resource "aws_lb" "example" {
  name = "example"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = "404"
    }
  }
}

resource "aws_security_group" "alb" {
  name = "alb"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "example" {
  name = "example"
  launch_configuration = aws_launch_configuration.example.name
  min_size = 2
  max_size = 10
  desired_capacity = 3
  vpc_zone_identifier = data.aws_subnets.default.ids
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 15
  }
}

resource "aws_security_group" "allow_http" {
  name = "allow_http"
  description = "Allow HTTP traffic"
  ingress {
    from_port = var.port
    to_port = var.port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.example.dns_name
}