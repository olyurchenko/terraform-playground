variable "db_name" {
  type = string
  default = "terraformdb"
}

variable "db_username" {
  type = string
  default = "dbadmin"
}

variable "db_instance_class" {
  type = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type = number
  default = 10
}

variable "region" {
  type = string
  default = "us-east-2"
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

variable "db_password" {
  type        = string
  description = "The password for the database"
}
