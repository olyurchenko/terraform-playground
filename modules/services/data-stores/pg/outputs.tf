
output "address" {
  description = "The address of the DB instance"
  value = aws_db_instance.db.address
}

output "port" {
  description = "The port of the DB instance"
  value = aws_db_instance.db.port
}
