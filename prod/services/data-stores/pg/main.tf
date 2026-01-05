terraform {
  backend "s3" {
    bucket = "oleksii-terraform-state-bucket"
    key    = "prod/services/data-stores/pg/terraform.tfstate"
    region = "us-east-2"
    profile = "default"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
}

module "db" {
  source = "git::https://github.com/olyurchenko/terafform-modules-playground.git//services/data-stores/pg?ref=data-stores-pg-v1.0.0"
  cluster_name = "prod"
  environment = "prod"
  db_remote_state_bucket = "oleksii-terraform-state-bucket"
  db_remote_state_key = "prod/services/data-stores/pg/terraform.tfstate"
  db_remote_state_region = "us-east-2"
  db_name = "prod"
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}


# trigger release test


data "aws_secretsmanager_secret" "db_password" {
  name = "db_password"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

