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

variable "tags" {
  description = "Tags applied to every resource in the module"
  type        = map(string)
  default     = {}
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

# Environment Variables

variable "postgres_url" {
  description = "The URL of the Postgres database"
  type        = string
}

variable "sqs_queue_url" {
  description = "The URL of the SQS queue"
  type        = string
  
}

variable "redis_url" {
  description = "The URL of the Redis cache"
  type        = string
}

variable "log_group_names" {
  description = "The names of the CloudWatch log groups"
  type        = map(string)
  default = {
    api-gateway = "api-gateway-log-group"
    order-service = "order-service-log-group"
    inventory-service = "inventory-service-log-group"
    payment-service = "payment-service-log-group"
    notification-service = "notification-service-log-group"
    shipping-service = "shipping-service-log-group"
    worker = "worker-log-group"
    scheduler = "scheduler-log-group"
    dashboard-api = "dashboard-api-log-group"
  }
}

variable "service_connect_log_group_names" {
  description = "The names of the CloudWatch log groups for service connect"
  type        = map(string)
  default = {
    api-gateway = "api-gateway-service-connect-log-group"
    order-service = "order-service-service-connect-log-group"
    inventory-service = "inventory-service-service-connect-log-group"
    payment-service = "payment-service-service-connect-log-group"
    notification-service = "notification-service-service-connect-log-group"
  }
}