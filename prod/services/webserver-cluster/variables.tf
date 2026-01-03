variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami" {
  type    = string
  default = "ami-0503ed50b531cc445"
}

variable "port" {
  type    = number
  default = 80
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
