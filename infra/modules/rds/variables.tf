variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod). dev uses a single NAT gateway."
  type        = string
}

variable "database_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "db_user" {
  description = "The username for the RDS instance"
  type        = string
}

variable "db_password" { 
  description = "The password for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "database_instance_class" {
  description = "The class of the RDS instance"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "region" {
  description = "The region of the application"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}