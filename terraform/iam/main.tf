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
    Region = var.region
    Project = var.project_name
  }
}

# Attach the ECS task execution role policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# Create an IAM role for the ECS task role
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"
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
    Region = var.region
    Project = var.project_name
  }
}

# Attach Policy that allows access to the Ecr
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}