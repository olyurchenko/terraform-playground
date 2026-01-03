variable "instance_type" {
  type    = string
  description = "The type of instance to use for the cluster"
  default     = "t2.micro"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "environment" {
  type        = string
  description = "The environment of the cluster"
}

variable "db_remote_state_bucket" {
  type        = string
  description = "The name of the bucket for the database remote state"
}

variable "db_remote_state_key" {
  type        = string
  description = "The key of the file for the database remote state"
}

variable "db_remote_state_region" {
  type        = string
  description = "The region of the bucket for the database remote state"
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


variable "min_size" {
  type        = number
  description = "The minimum number of instances in the cluster"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "The maximum number of instances in the cluster"
  default     = 10
}

variable "desired_capacity" {
  type        = number
  description = "The desired number of instances in the cluster"
  default     = 3
}

variable "db_address" {
  type        = string
  description = "The address of the database"
}

variable "db_port" {
  type        = number
  description = "The port of the database"
}
