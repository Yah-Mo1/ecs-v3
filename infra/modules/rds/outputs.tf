output "db_password" {
  value = aws_db_instance.database_instance.password
  sensitive = true
}