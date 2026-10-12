# Create an IAM role for the ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Environment = var.environment
    Region      = var.region
    Project     = var.project_name
  }
}

# Attach the ECS task execution role policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Create an IAM role for the Scheduler ECS task role
resource "aws_iam_role" "rds_and_sqs_ecs_task_role" {
  name = "${var.project_name}-${var.environment}-rds-and-sqs-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Environment = var.environment
    Region      = var.region
    Project     = var.project_name
  }
}


# Scheduler task requires access to RDS database
resource "aws_iam_role_policy_attachment" "scheduler_ecs_task_role_policy_attachment" {
  role       = aws_iam_role.rds_and_sqs_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}

# Scheduler task requires access to SQS queue
resource "aws_iam_role_policy_attachment" "rds_and_sqs_ecs_task_role_policy_attachment" {
  role       = aws_iam_role.rds_and_sqs_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}


//Create policy for Redis Cache


#TODO: Look into this --> Create a queue policy for the orders queue to allow the ECS tasks to send messages to the queue
