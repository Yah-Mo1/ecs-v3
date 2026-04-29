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


variable "service_names" {
  description = "The list of service names to create ECR repositories for"
  type        = list(map(string))
  default = [
    {
      name = "api-gateway"
      port = 8080
    },
    {
      name = "order-service"
      port = 8081
    },
    {
      name = "inventory-service"
      port = 8082
    },
    {
      name = "payment-service"
      port = 8083
    },
    {
      name = "notification-service"
      port = 8084
    },
    {
      name = "shipping-service"
      port = 8085
    },
    {
      name = "worker"
    },
    {
      name = "scheduler"
    },
    {
      name = "dashboard-api"
      port = 8086
    }
  ]
}

variable "ecr_repositories" {
  description = "The list of ECR repositories"
  type        = list(string)
}