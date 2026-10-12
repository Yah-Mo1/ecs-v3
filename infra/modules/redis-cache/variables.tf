variable "environment" {
  description = "The environment of the application"
  type        = string
}

variable "tags" {
  description = "The tags of the application"
  type        = map(string)
}

variable "project_name" {
  description = "The name of the project"
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