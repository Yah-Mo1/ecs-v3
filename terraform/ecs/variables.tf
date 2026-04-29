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


variable "alb_id" {
  description = "The ID of the ALB to attach the ECS services to"
  type        = string
  
}

variable "vpc_id" {
  description = "The ID of the VPC to create the ECS services in"
  type        = string
  
}

variable "alb_sg_id" {
  description = "The ID of the Security Group for the ALB to allow traffic from the ECS services"
  type        = string
  
}

variable "private_subnet_ids" {
  description = "The IDs of the subnets to create the ECS services in"
  type        = list(string)
  
}

variable "target_group_arn" {
  description = "The ARN of the Target Group to attach the ECS services to"
  type        = string
  
}

variable "ecs_task_role" {
  description = "The ARN of the IAM Role to use for the ECS Task"
  type        = string
}

variable "ecs_execution_role" {
  description = "The ARN of the IAM Role to use for the ECS Task Execution"
  type        = string
}