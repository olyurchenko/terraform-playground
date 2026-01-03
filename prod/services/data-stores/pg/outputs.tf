
output "address" {
  description = "The address of the DB instance for the prod environment"
  value = module.db.address
}

output "port" {
  description = "The port of the DB instance for the prod environment"
  value = module.db.port
}
