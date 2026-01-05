terraform {
  backend "s3" {
    bucket = "oleksii-terraform-state-bucket"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"
    profile = "default"
    use_lockfile = true
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "oleksii-terraform-state-bucket"
    key    = "stage/services/data-stores/pg/terraform.tfstate"
    region = "us-east-2"
  }
}

module "webserver-cluster" {
  source = "git::https://github.com/olyurchenko/terafform-modules-playground.git//services/webserver-cluster?ref=services-webserver-cluster-v1.0.0"
  region = var.region
  ami = var.ami
  port = var.port
  cluster_name = "webserver-stage"
  environment = "stage"
  db_remote_state_bucket = "oleksii-terraform-state-bucket"
  db_remote_state_key = "stage/services/data-stores/pg/terraform.tfstate"
  db_remote_state_region = "us-east-2"
  min_size = 2
  max_size = 6
  desired_capacity = 3
  instance_type = "t2.micro"
  db_address = data.terraform_remote_state.db.outputs.address
  db_port = data.terraform_remote_state.db.outputs.port
}
