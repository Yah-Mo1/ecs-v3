variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

variable "domain_name" {
    description = "The Domain name that the acm certificate can reference"
    type = string
  
}