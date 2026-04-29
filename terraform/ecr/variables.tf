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

variable "service_names" {
  description = "The list of service names to create ECR repositories for"
  type        = list(string)
  default = [
    "api-gateway",
    "order-service",
    "inventory-service",
    "payment-service",
    "notification-service",
    "shipping-service",
    "worker",
    "scheduler",
    "dashboard-api",
  ]
}