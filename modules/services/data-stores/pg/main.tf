
locals {
  engine_version = "17.2"
  storage_type = "gp2"
  engine = "postgres"
}

resource "aws_db_instance" "db" {
  identifier_prefix = "${var.cluster_name}-${var.environment}-db"
  engine = local.engine
  engine_version = local.engine_version
  instance_class = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type = local.storage_type
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true

  lifecycle {
    create_before_destroy = true
  }
}
