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

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "terraform-example"
  }
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  user_data_replace_on_change = true
  user_data = <<EOF
#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "Hello, World!" > /var/www/html/index.html
EOF
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

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}