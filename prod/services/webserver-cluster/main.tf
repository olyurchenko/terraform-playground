provider "aws" {
  region = var.region
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "oleksii-terraform-state-bucket"
    key    = "prod/services/data-stores/pg/terraform.tfstate"
    region = "us-east-2"
  }
}

module "webserver-cluster" {
  source = "../../../modules/services/webserver-cluster"
  region = var.region
  ami = var.ami
  port = var.port
  cluster_name = "webserver-prod"
  environment = "prod"
  db_remote_state_bucket = "oleksii-terraform-state-bucket"
  db_remote_state_key = "prod/services/data-stores/pg/terraform.tfstate"
  db_remote_state_region = "us-east-2"
  min_size = 3
  max_size = 12
  desired_capacity = 4
  instance_type = "t2.micro"
  db_address = data.terraform_remote_state.db.outputs.address
  db_port = data.terraform_remote_state.db.outputs.port
}
