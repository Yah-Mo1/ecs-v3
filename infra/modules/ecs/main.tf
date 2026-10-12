
#TODO: Reference IAM roles from the IAM module instead of creating new ones here
# TODO: Cloudwatch log group and security group should be created in the cloudwatch and security group modules respectively
# TODO: Cloudwatch log groups should be per service

locals {
  service_name_sg        = "${var.project_name}-${var.environment}-ecs-service-security-group"
}


# Fetch existing ECR repositories
data "aws_ecr_repository" "ecr_repositories" {
  for_each = toset(var.service_names)
  name     = each.value
}


# Create a Service Discovery namespace
resource "aws_service_discovery_http_namespace" "service_discovery_namespace" {
  name        = "${var.project_name}-${var.environment}-service-discovery-namespace"
  description = "Namespace for Service Discovery"
}


#Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-ecs-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.service_discovery_namespace.name
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecs-cluster-${var.environment}"
  })
}

# Set up the ECS capacity provider for the ECS cluster
resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_provider" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "scheduler_service_task_definition" {
  family                   = "scheduler-service-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "scheduler-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["scheduler"].repository_url}:latest"
  
    environment    = [
      {
        name  = "DATABASE_URL"
        value = var.postgres_url
      }
    ]
    
    log_group = var.log_group_names["scheduler"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-scheduler-service-task-definition"
  })
}

# Create ECS Service for Scheduler service

resource "aws_ecs_service" "scheduler_service" {
  name            = "scheduler-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.scheduler_service_task_definition.arn
  desired_count   = 1 //
  iam_role        = var.ecs_task_role // This task role may require access to the database 

  tags = merge(var.tags, {
    Name = "${var.project_name}-scheduler-service"
  })
}


# Dashboard API service task definition
resource "aws_ecs_task_definition" "dashboard_api_service_task_definition" {
  family                   = "dashboard-api-service-${var.environment}" 
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role


  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "dashboard-api-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["dashboard-api"].repository_url}:latest"
      
    container_port = 8086
    host_port      = 8086
    protocol       = "tcp"

    environment    = [
      {
        name  = "DATABASE_URL"
        value = var.postgres_url
      }
    ]
    
    log_group = var.log_group_names["dashboard-api"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-dashboard-api-service-task-definition"
  })
}

#Dashboard API service ECS service
resource "aws_ecs_service" "dashboard_api_service" {
  name            = "dashboard-api-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.dashboard_api_service_task_definition.arn
  desired_count   = 1
  iam_role        = var.ecs_task_role // This task role may require access to the database 
}



# Shipping service task definition
resource "aws_ecs_task_definition" "shipping_service_task_definition" {
  family                   = "shipping-service-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "shipping-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["shipping"].repository_url}:latest"
    
    container_port = 8085
    host_port      = 8085
    protocol       = "tcp"
    
    environment    = [
      {
        name  = "DATABASE_URL"
        value = var.postgres_url
      },
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      }
    ]
    
    log_group = var.log_group_names["shipping-service"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-shipping-service-task-definition"
  })
}

# Shipping service ECS service
resource "aws_ecs_service" "shipping_service" {
  name            = "shipping-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.shipping_service_task_definition.arn
  desired_count   = 1
  iam_role        = var.ecs_task_role // This task role may require access to the database 
}


# Order service task definition
resource "aws_ecs_task_definition" "order_service_task_definition" {
  family                   = "order-service-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role


  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "order-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["order-service"].repository_url}:latest"
    
    container_port = 8081
    host_port      = 8081
    protocol       = "tcp"
    
    environment    = [
      {
        name  = "DATABASE_URL"
        value = var.postgres_url
      },
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      }
    ]

    log_group = var.log_group_names["order-service"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
    }

  tags = merge(var.tags, {
    Name = "${var.project_name}-order-service-task-definition"
  })

}

# Order service ECS service
resource "aws_ecs_service" "order_service" {
  name            = "order-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.order_service_task_definition.arn
  desired_count   = 1
  iam_role        = var.ecs_task_role // This task role may require access to the database 

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_discovery_namespace.arn

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = var.service_connect_log_group_names["order-service"]
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "service-connect"
      }
    }

    access_log_configuration {
      format                   = "TEXT"
      include_query_parameters = "ENABLED"
    }

    service {
      port_name      = "http"
      discovery_name = "order-service"

      client_alias {
        dns_name = "order-service"
        port     = 8081
      }
    }
  }

}

# Inventory service task definition
resource "aws_ecs_task_definition" "inventory_service_task_definition" {
  family                   = "inventory-service-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role

  
  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "inventory-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["inventory-service"].repository_url}:latest"
    
    container_port = 8082
    host_port      = 8082
    protocol       = "tcp"
    
    environment    = [
      {
        name  = "DATABASE_URL"
        value = var.postgres_url
      }
    ]
    
    log_group = var.log_group_names["inventory-service"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-inventory-service-task-definition"
  })
}

# Inventory service ECS service
resource "aws_ecs_service" "inventory_service" {
  name            = "inventory-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.inventory_service_task_definition.arn
  desired_count   = 1
  iam_role        = var.ecs_task_role // This task role may require access to the database

   service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_discovery_namespace.arn

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = var.service_connect_log_group_names["inventory-service"]
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "service-connect"
      }
    }

    access_log_configuration {
      format                   = "TEXT"
      include_query_parameters = "ENABLED"
    }

    service {
      port_name      = "http"
      discovery_name = "inventory-service"

      client_alias {
        dns_name = "inventory-service"
        port     = 8082
      }
    }
  } 

}


# Payment service task definition
resource "aws_ecs_task_definition" "payment_service_task_definition" {
  family                   = "payment-service-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "payment-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["payment-service"].repository_url}:latest"
    
    container_port = 8083
    host_port      = 8083
    protocol       = "tcp"
  
    environment    = [
      {
        name  = "DATABASE_URL"
        value = var.postgres_url
      },
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      }
    ]
    
    log_group = var.log_group_names["payment-service"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-payment-service-task-definition"
  })
}

# Payment service ECS service
resource "aws_ecs_service" "payment_service" {
  name            = "payment-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.payment_service_task_definition.arn
  desired_count   = 1
  iam_role        = var.ecs_task_role // This task role may require access to the database 

   service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_discovery_namespace.arn

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = var.service_connect_log_group_names["payment-service"]
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "service-connect"
      }
    }

    access_log_configuration {
      format                   = "TEXT"
      include_query_parameters = "ENABLED"
    }

    service {
      port_name      = "http"
      discovery_name = "payment-service"

      client_alias {
        dns_name = "payment-service"
        port     = 8083
      }
    }
  }
}


# Notification service task definition
resource "aws_ecs_task_definition" "notification_service_task_definition" {
  family                   = "notification-service-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "notification-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["notification-service"].repository_url}:latest"
    
    container_port = 8084
    host_port      = 8084
    protocol       = "tcp"
    
    environment    = [
      {
        name  = "DATABASE_URL"
        value = var.postgres_url
      }
    ]
    
    log_group = var.log_group_names["notification-service"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-notification-service-task-definition"
  })
}

# Notification service ECS service
resource "aws_ecs_service" "notification_service" {
  name            = "notification-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.notification_service_task_definition.arn
  desired_count   = 1
  iam_role        = var.ecs_task_role // This task role may require access to the database 

   service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_discovery_namespace.arn

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = var.service_connect_log_group_names["notification-service"]
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "service-connect"
      }
    }

    access_log_configuration {
      format                   = "TEXT"
      include_query_parameters = "ENABLED"
    }

    service {
      port_name      = "http"
      discovery_name = "notification-service"

      client_alias {
        dns_name = "notification-service"
        port     = 8084
      }
    }
  }
}



//Create api gateway service

# Notification service task definition API-Gateway service
resource "aws_ecs_task_definition" "api_gateway_service_task_definition" {
  family                   = "api-gateway-service-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "api-gateway-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["api-gateway"].repository_url}:latest"
    
    container_port = 8080
    host_port      = 8080
    protocol       = "tcp"
    
    environment    = [
      {
        name  = "REDIS_URL"
        value = var.redis_url
      }
    ]
    
    log_group = var.log_group_names["api-gateway"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-api-gateway-service-task-definition"
  })
}

# API Gateway service ECS service
resource "aws_ecs_service" "api_gateway_service" {
  name            = "api-gateway-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api_gateway_service_task_definition.arn
  desired_count   = 1
  iam_role        = var.ecs_task_role // This task role may require access to the database 

   service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_discovery_namespace.arn

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = var.service_connect_log_group_names["api-gateway"]
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "service-connect"
      }
    }

    access_log_configuration {
      format                   = "TEXT"
      include_query_parameters = "ENABLED"
    }

    service {
      port_name      = "http"
      discovery_name = "api-gateway-service"

      client_alias {
        dns_name = "api-gateway-service"
        port     = 8080
      }
    }
  }
}


//Create worker service
# Worker service task definition
resource "aws_ecs_task_definition" "worker_service_task_definition" {
  family                   = "worker-service-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = templatefile("${path.module}/task-def.tpl", {
    container_name = "worker-service-container-${var.environment}"
    image          = "${data.aws_ecr_repository.ecr_repositories["worker"].repository_url}:latest"
    
    
    environment    = [
      {
        name  = "SQS_QUEUE_URL"
        value = var.sqs_queue_url
      }
    ]
    
    log_group = var.log_group_names["worker"]
    region    = var.region
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-worker-service-task-definition"
  })
}

# Worker service ECS service
resource "aws_ecs_service" "worker_service" {
  name            = "worker-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker_service_task_definition.arn
  desired_count   = 1
  iam_role        = var.ecs_task_role // This task role may require access to the database 
}


#TODO: Services that are public facing - Load Balancing (Optional): If public-facing, attach an Application Load Balancer and map unique listener rules or target groups for this specific port/service.

# Create the Security Group for the ECS Service
resource "aws_security_group" "ecs_sg" {
    name        = local.service_name_sg
    description = "Security group for the ECS Service"
    vpc_id      = var.vpc_id

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags, {
        Name = "${var.project_name}-ecs-service-sg-${var.environment}"
    })
}