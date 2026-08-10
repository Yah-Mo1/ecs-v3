variable "environment" {
  description = "The environment"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}


variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}