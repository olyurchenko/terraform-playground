

locals {
  port = 80
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_launch_template" "cluster_launch_template" {
  name_prefix   = "${var.cluster_name}-launch-template"
  instance_type = var.instance_type
  image_id      = var.ami
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    server_port = var.port
    db_address  = var.db_address
    db_port     = var.db_port
  }))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_http.id]
  }

  tags = {
    Name        = "${var.cluster_name}-launch-template"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb" "cluster_alb" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.cluster_name}-alb"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cluster_alb.arn
  port              = local.port
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
  ingress {
    from_port   = local.port
    to_port     = local.port
    protocol    = local.protocol
    cidr_blocks = local.cidr_blocks
  }
  egress {
    from_port   = local.from_port
    to_port     = local.to_port
    protocol    = local.protocol
    cidr_blocks = local.cidr_blocks
  }

  tags = {
    Name        = "${var.cluster_name}-alb"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster_asg" {
  name = "${var.cluster_name}-asg"
  launch_template {
    id      = aws_launch_template.cluster_launch_template.id
    version = "$Latest"
  }
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = data.aws_subnets.default.ids
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-${var.environment}"
    propagate_at_launch = true
  }
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

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
  name_prefix = "ws-asg"
  port        = var.port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 15
  }

  tags = {
    Name        = "${var.cluster_name}-asg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_http" {
  name        = "${var.cluster_name}-allow-http"
  description = "Allow HTTP traffic"
  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = local.from_port
    to_port     = local.to_port
    protocol    = local.protocol
    cidr_blocks = local.cidr_blocks
  }

  tags = {
    Name        = "${var.cluster_name}-allow-http"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
