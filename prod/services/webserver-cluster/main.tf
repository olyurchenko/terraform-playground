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


resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  autoscaling_group_name = module.webserver-cluster.autoscaling_group_name
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  autoscaling_group_name = module.webserver-cluster.autoscaling_group_name
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
}

module "webserver-cluster" {
  source = "git::https://github.com/olyurchenko/terafform-modules-playground.git//services/webserver-cluster?ref=services-webserver-cluster-v1.0.0"
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
