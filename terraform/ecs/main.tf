locals {
  service_log_group_name = "${var.project_name}-${var.environment}-ecs-service-log-group"
  service_name_sg = "${var.project_name}-${var.environment}-ecs-service-security-group"
}

#TODO: Reference IAM roles from the IAM module instead of creating new ones here

# Create a CloudWatch log group for each service
resource "aws_cloudwatch_log_group" "service_log_group" {
  for_each = toset(var.service_names)
  name = "${local.service_log_group_name}-${each.value.name}"
  tags = {
    Environment = var.environment
    Region = var.region
    Project = var.project_name
  }
}

#Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Environment = var.environment
    Region = var.region
    Project = var.project_name
  }
}


# Attach the ECS capacity provider to the ECS cluster
resource "aws_ecs_cluster_capacity_providers" "ecs-capacity_provider" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Create ECS Task Definition
# Create a task definition for each service
# For each service, create a task definition with the following:
# - A container definition with the following:
#   - A name
#   - An image
#   - A CPU
#   - A memory
#   - An essential flag
#   - A port mapping
#   - A health check


resource "aws_ecs_task_definition" "service_task_definition" {
  for_each = toset(var.service_names)
  family = each.value.name
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "1024"
  memory = "2048"
  execution_role_arn = var.ecs_execution_role
  task_role_arn = var.ecs_task_role
  tags = {
    Environment = var.environment
    Region = var.region
    Project = var.project_name
  }
  container_definitions = jsonencode([
    {
      name      = each.value.name
      image     = "${var.ecr_repositories[each.value.name].repository_url}:v1.0.0"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
        }
      ]
      logConfiguration = templatefile("${path.module}/task-def.tpl", each.value.name,{
        logDriver = "awslogs"
        awslogs-group = "${aws_cloudwatch_log_group.service_log_group[each.value.name].name}"
        awslogs-region = var.region
        awslogs-stream-prefix = "ecs-${each.value.name}"
      })
    }
  ])

  # volume {
  #   name      = "service-storage"
  #   host_path = "/ecs/service-storage"
  # }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}



# Create ECS Service for each service

resource "aws_ecs_service" "service" {
  for_each = toset(var.service_names)
  name            = each.value.name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service_task_definition[each.value.name].arn
  desired_count   = 1
  iam_role        = var.ecs_task_role
  # depends_on      = [aws_iam_role_policy_attachment.ecs_task_role_policy_attachment]

  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = each.value.name
    container_port   = 8080
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${join(",", data.aws_availability_zones.available.names)}]"
  }
}



# Create the Security Group for the ECS Service


resource "aws_security_group" "alb_sg" {
    name        = local.service_name_sg
    description = "Security group for the ALB"
    vpc_id      = var.vpc_id
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [var.alb_sg_id]
        
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}